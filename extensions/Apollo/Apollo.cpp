constexpr char __lua_ref_init[] = R"(
(function()
	local _create_lua_ref_struct = __apollo_tmp
	__apollo_tmp = nil
	local _uid_to_ref = {}
	local _ref_to_rvalue = {}
	local _next_uid = 100000
	__apollo_ref_to_rvalue = function(ref)
		local rv = _ref_to_rvalue[ref]
		if (rv == nil) then
			local uid = _next_uid
			_next_uid = _next_uid + 1
			rv = _create_lua_ref_struct(uid, ref)
			_ref_to_rvalue[ref] = rv;
			_uid_to_ref[uid] = ref
			--print("created ref", ref, uid, rv)
		end
		return rv
	end
	__apollo_uid_free = function(uid)
		local ref = _uid_to_ref[uid]
		if (ref ~= nil) then
			_uid_to_ref[uid] = nil
			_ref_to_rvalue[ref] = nil
		end
	end
	__apollo_uid_to_ref = function(uid)
		return _uid_to_ref[uid]
	end
	__apollo_ref_get_index = function(uid, index)
		return _uid_to_ref[uid][index]
	end
	__apollo_ref_get_length = function(uid)
		return #_uid_to_ref[uid]
	end
	__apollo_ref_set_index = function(uid, index, value)
		_uid_to_ref[uid][index] = value
	end
	__apollo_ref_invoke = function(uid, ...)
		return _uid_to_ref[uid](...)
	end
	__apollo_ref_typeof = function(uid)
		return type(_uid_to_ref[uid])
	end
end)()
)";#pragma once
#include "stdafx.h"
#include <string>
#include "gml_api.h"

struct lua_next_error_t {
	bool hasValue = false;
	std::string text;
	void set(const char* _text) {
		text = _text;
	}
	const char* pop() {
		if (hasValue) {
			hasValue = false;
			return text.c_str();
		} else return nullptr;
	}
};
extern lua_next_error_t lua_next_error;

namespace Apollo {
	inline void clearError() {
		lua_next_error.hasValue = false;
	}
	inline void checkError(lua_State* L) {
		auto error_text = lua_next_error.pop();
		if (error_text) {
			lua_pushstring(L, error_text);
			lua_error(L);
		}
	}
	/// Submits the error to the GML callback
	void handleLuaError(lua_State* L, ApolloState* state = nullptr);
	/// For Watch. Reuses the return buffer.
	const char* printLuaStack(lua_State* L, const char* label = "Stack");
	ApolloState* getState(lua_State* L);

	void luaToGML(RValue* result, lua_State* L, int idx);
	void popLuaStackValue(RValue* result, lua_State* L);
	void popLuaStackValuesAsArray(RValue* result, lua_State* L, int count = LUA_MULTRET);
	void pushGMLtoLuaStack(RValue* value, lua_State* L);

	//
	void createLuaRef(RValue* result, lua_State* L, int ind);
}

template<typename T> T* lua_newuserdata_t(lua_State* L) {
	return (T*)lua_newuserdatauv(L, sizeof(T), 1);
};

#define luaL_dostring_trace(L, name, code) \
	if (luaL_loadbuffer(L,code,strlen(code),name) || lua_pcall(L, 0, LUA_MULTRET, 0)) {\
		printf("Error executing %s: %s\n", name, lua_tostring(L, -1));\
		fflush(stdout);\
	}

#define dllm_handle_lua_error(call) if (call) { Apollo::handleLuaError(L); return; }#pragma once
#include <vector>
extern "C" {
	#include "./../Lua/lua.h"
	#include "./../Lua/lualib.h"
	#include "./../Lua/lauxlib.h"
}

struct RValue;
class ApolloState {
public:
	lua_State* luaState;
	ApolloState* parent;
	RValue* selfValue = nullptr;
	RValue* callArgs = nullptr;
	std::vector<ApolloState*> children{};
	ApolloState(lua_State* _state, ApolloState* _parent) : luaState(_state), parent(_parent) {
		//
	}
	~ApolloState() {
		for (auto& child : children) {
			delete child;
		}
		lua_close(luaState);
	}
};#pragma once
#include "stdafx.h"

struct gml_Func_t {
	YYFunc script_execute = nullptr;
	YYFunc asset_get_index = nullptr;
};
extern gml_Func_t gml_Func;

void YYCreateEmptyArray(RValue* result, int size);

namespace GML {
	extern RValue* defaultSelf;
	inline void script_execute_def(RValue& result, RValue* arg, int argc) {
		gml_Func.script_execute(result, (CInstance*)defaultSelf->ptr, (CInstance*)defaultSelf->ptr, argc, arg);
	}
	template<size_t size> void script_execute_def(RValue& result, RValue(&args)[size]) {
		script_execute_def(result, args, (int)size);
	}

	/// runs script, checks for lua_show_error
	template<size_t size> void script_execute_def_for(RValue& result, RValue(&args)[size], lua_State* L) {
		Apollo::clearError();
		script_execute_def(result, args, (int)size);
		Apollo::checkError(L);
	}

	inline int asset_get_index(const char* name) {
		RValue arg{}, result{};
		YYCreateString(&arg, name);
		gml_Func.asset_get_index(result, nullptr, nullptr, 1, &arg);
		arg.free();
		return result.getInt32(-1);
	}
}

struct gml_Script_t {
	int init(const char* name);
	#define X(name) int name = init(#name)
	X(lua_ref_create_raw);
	X(lua_ref_create_raw_table);
	X(lua_ref_create_raw_function);
	X(lua_ref_create_raw_userdata);
	X(lua_proc_error_raw);
	X(lua_gml_ref_to_uid);
	X(lua_gml_ref_free);
	// GmlArray:
	X(lua_gml_ref_get_length);
	X(lua_gml_ref_get_index);
	X(lua_gml_ref_set_index);
	// GmlStruct:
	X(lua_gml_ref_get_key);
	X(lua_gml_ref_set_key);
	X(lua_gml_ref_invoke);
	// GmlCrossRef:
	X(lua_gml_cross_ref_get_key);
	X(lua_gml_cross_ref_set_key);
	X(lua_gml_cross_ref_invoke);
	#undef X
};
extern gml_Script_t gml_Script;
#pragma once
#include <vector>
#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#include <optional>
#endif
#include <stdint.h>
#include <cstring>
#include <tuple>
using namespace std;

#define dllg /* tag */
#define dllgm /* tag;mangled */

#if defined(_WINDOWS)
#define dllx extern "C" __declspec(dllexport)
#define dllm __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#define dllm __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#define dllm /* */
#endif

#ifdef _WINDEF_
/// auto-generates a window_handle() on GML side
typedef HWND GAME_HWND;
#endif

/// auto-generates an asset_get_index("argument_name") on GML side
typedef int gml_asset_index_of;
/// Wraps a C++ pointer for GML.
template <typename T> using gml_ptr = T*;
/// Same as gml_ptr, but replaces the GML-side pointer by a nullptr after passing it to C++
template <typename T> using gml_ptr_destroy = T*;

class gml_buffer {
private:
	uint8_t* _data;
	int32_t _size;
	int32_t _tell;
public:
	gml_buffer() : _data(nullptr), _tell(0), _size(0) {}
	gml_buffer(uint8_t* data, int32_t size, int32_t tell) : _data(data), _size(size), _tell(tell) {}

	inline uint8_t* data() { return _data; }
	inline int32_t tell() { return _tell; }
	inline int32_t size() { return _size; }
};

class gml_istream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_istream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> T read() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		T result{};
		std::memcpy(&result, pos, sizeof(T));
		pos += sizeof(T);
		return result;
	}

	char* read_string() {
		char* r = (char*)pos;
		while (*pos != 0) pos++;
		pos++;
		return r;
	}

	template<class T> std::vector<T> read_vector() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		auto n = read<uint32_t>();
		std::vector<T> vec(n);
		std::memcpy(vec.data(), pos, sizeof(T) * n);
		pos += sizeof(T) * n;
		return vec;
	}
	std::vector<const char*> read_string_vector() {
		auto n = read<uint32_t>();
		std::vector<const char*> vec(n);
		for (auto i = 0u; i < n; i++) {
			vec[i] = read_string();
		}
		return vec;
	}

	gml_buffer read_gml_buffer() {
		auto _data = (uint8_t*)read<int64_t>();
		auto _size = read<int32_t>();
		auto _tell = read<int32_t>();
		return gml_buffer(_data, _size, _tell);
	}

	#pragma region Tuples
	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	std::tuple<Args...> read_tuple() {
		std::tuple<Args...> tup;
		std::apply([this](auto&&... arg) {
			((
				arg = this->read<std::remove_reference_t<decltype(arg)>>()
				), ...);
			}, tup);
		return tup;
	}

	template<class T> optional<T> read_optional() {
		if (read<bool>()) {
			return read<T>;
		} else return {};
	}
	#else
	template<class A, class B> std::tuple<A, B> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		return std::tuple<A, B>(a, b);
	}

	template<class A, class B, class C> std::tuple<A, B, C> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		return std::tuple<A, B, C>(a, b, c);
	}

	template<class A, class B, class C, class D> std::tuple<A, B, C, D> read_tuple() {
		A a = read<A>();
		B b = read<B>();
		C c = read<C>();
		D d = read<d>();
		return std::tuple<A, B, C, D>(a, b, c, d);
	}
	#endif
};

class gml_ostream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_ostream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> void write(T val) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		memcpy(pos, &val, sizeof(T));
		pos += sizeof(T);
	}

	void write_string(const char* s) {
		for (int i = 0; s[i] != 0; i++) write<char>(s[i]);
		write<char>(0);
	}

	template<class T> void write_vector(std::vector<T>& vec) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		auto n = vec.size();
		write<uint32_t>((uint32_t)n);
		memcpy(pos, vec.data(), n * sizeof(T));
		pos += n * sizeof(T);
	}

	void write_string_vector(std::vector<const char*> vec) {
		auto n = vec.size();
		write<uint32_t>((uint32_t)n);
		for (auto i = 0u; i < n; i++) {
			write_string(vec[i]);
		}
	}

	#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
	template<typename... Args>
	void write_tuple(std::tuple<Args...> tup) {
		std::apply([this](auto&&... arg) {
			(this->write(arg), ...);
			}, tup);
	}

	template<class T> void write_optional(optional<T>& val) {
		auto hasValue = val.has_value();
		write<bool>(hasValue);
		if (hasValue) write<T>(val.value());
	}
	#else
	template<class A, class B> void write_tuple(std::tuple<A, B>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
	}
	template<class A, class B, class C> void write_tuple(std::tuple<A, B, C>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
	}
	template<class A, class B, class C, class D> void write_tuple(std::tuple<A, B, C, D>& tup) {
		write<A>(std::get<0>(tup));
		write<B>(std::get<1>(tup));
		write<C>(std::get<2>(tup));
		write<D>(std::get<3>(tup));
	}
	#endif
};
#pragma once
#define GDKEXTENSION_EXPORTS
#define __YYDEFINE_EXTENSION_FUNCTIONS__
#include "YYRunnerInterface.h"

const int VALUE_REAL = 0;		// Real value
const int VALUE_STRING = 1;		// String value
const int VALUE_ARRAY = 2;		// Array value
const int VALUE_OBJECT = 6;		// YYObjectBase* value 
const int VALUE_INT32 = 7;		// Int32 value
const int VALUE_UNDEFINED = 5;	// Undefined value
const int VALUE_PTR = 3;		// Ptr value
const int VALUE_VEC3 = 4;		// Deprecated : unused : Vec3 (x,y,z) value (within the RValue)
const int VALUE_VEC4 = 8;		// Deprecated : unused :Vec4 (x,y,z,w) value (allocated from pool)
const int VALUE_VEC44 = 9;		// Deprecated : unused :Vec44 (matrix) value (allocated from pool)
const int VALUE_INT64 = 10;		// Int64 value
const int VALUE_ACCESSOR = 11;	// Actually an accessor
const int VALUE_NULL = 12;		// JS Null
const int VALUE_BOOL = 13;		// Bool value
const int VALUE_ITERATOR = 14;	// JS For-in Iterator
const int VALUE_REF = 15;		// Reference value (uses the ptr to point at a RefBase structure)
const int MASK_KIND_RVALUE = 0x0ffffff;
const int VALUE_UNSET = MASK_KIND_RVALUE;

struct RValue;
#define YYFuncArgs RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg
typedef void(*YYFunc) (YYFuncArgs);

#pragma region Offsets and class names
template<typename T> struct FieldOffset {
	int64_t offset = 0;
	FieldOffset() {}
	FieldOffset(const int64_t _offset) : offset(_offset) {}
	inline T read(void* obj) {
		return *(T*)((uint8_t*)obj + offset);
	}
};
struct GmlOffsets {
	struct {
		FieldOffset<void*> weakRef{};
	} CWeakRef;
	struct {
		FieldOffset<YYFunc> cppFunc{};
	} CScriptRef;
	struct {
		FieldOffset<RValue*> items{};
		FieldOffset<int> length{};
	} RefDynamicArrayOfRValue;
	struct {
		FieldOffset<const char*> className{};
	} YYObjectBase;
};
extern GmlOffsets gmlOffsets;

struct GmlClassOf {
	const char* LuaState;

	const char* LuaRef;
	const char* LuaTable;
	const char* LuaFunction;
	const char* LuaUserdata;
	inline bool isLuaRef(const char* valClass) {
		return(valClass == LuaRef
			|| valClass == LuaTable
			|| valClass == LuaFunction
			|| valClass == LuaUserdata
		);
	}
};
extern GmlClassOf gmlClassOf;
#pragma endregion

class CInstance;
class ApolloState;
struct lua_State;

struct RefString {
	const char* text;
	int refCount;
	int size;
};

struct RValue {
	union {
		int v32;
		int64_t v64;
		double val;
		RefString* str;
		void* ptr = 0;
	};
	uint32_t flags = 0;
	uint32_t kind = VALUE_REAL;

	inline bool needsFree() {
		const auto flagSet = (1 << VALUE_STRING) | (1 << VALUE_OBJECT) | (1 << VALUE_ARRAY);
		return ((1 << (kind & 31)) & flagSet) != 0;
	}
	inline void free() {
		if (needsFree()) FREE_RValue(this);
	}

	inline void setReal(double value) {
		free();
		kind = VALUE_REAL;
		val = value;
	}
	inline void setInt64(int64_t value) {
		free();
		kind = VALUE_INT64;
		v64 = value;
	}
	inline void setScriptID(int64_t value) {
		free();
		kind = VALUE_INT64;
		v64 = value;
	}
	inline void setTo(RValue* value) {
		COPY_RValue(this, value);
	}

	inline int getInt32(int defValue = 0) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: return (int)val;
			case VALUE_INT32: case VALUE_REF: return v32;
			case VALUE_INT64: return (int)v64;
			default: return defValue;
		}
	}
	inline int64_t getInt64(int64_t defValue = 0) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: return (int64_t)val;
			case VALUE_INT32: case VALUE_REF: return v32;
			case VALUE_INT64: return v64;
			default: return defValue;
		}
	}
	inline const char* getString(const char* defValue = nullptr) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_STRING) {
			return str->text;
		} else return defValue;
	}

	inline bool tryGetInt(int& result) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: result = (int)val; return true;
			case VALUE_INT32: case VALUE_REF: result = v32; return true;
			case VALUE_INT64: result = (int)v64; return true;
			default: return false;
		}
	}
	inline bool tryGetInt64(int64_t& result) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_REAL: case VALUE_BOOL: result = (int64_t)val; return true;
			case VALUE_INT32: case VALUE_REF: result = v32; return true;
			case VALUE_INT64: result = v64; return true;
			default: return false;
		}
	}
	inline bool tryGetPtr(void*& result) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_PTR) {
			result = ptr;
			return true;
		} else return false;
	}
	inline bool tryGetString(const char*& result) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_STRING) {
			result = str->text;
			return true;
		} else return false;
	}
	inline bool tryGetArrayItems(RValue*& items, int& length) {
		if ((kind & MASK_KIND_RVALUE) == VALUE_ARRAY) {
			length = getArrayLength();
			items = getArrayItems();
			return true;
		} else return false;
	}

	#pragma region offset stuff
	inline bool weakRefIsAlive() {
		return gmlOffsets.CWeakRef.weakRef.read(ptr) != nullptr;
	}
	inline YYFunc getCppFunc() {
		return gmlOffsets.CScriptRef.cppFunc.read(ptr);
	}
	inline int getArrayLength() {
		return gmlOffsets.RefDynamicArrayOfRValue.length.read(ptr);
	}
	inline RValue* getArrayItems() {
		return gmlOffsets.RefDynamicArrayOfRValue.items.read(ptr);
	}
	inline RValue* getArrayItem(int index) {
		return gmlOffsets.RefDynamicArrayOfRValue.items.read(ptr) + index;
	}
	inline const char* getObjectClass() {
		return gmlOffsets.YYObjectBase.className.read(ptr);
	}
	#pragma endregion

	inline RValue* getStructMember(const char* field) {
		return YYStructGetMember(this, field);
	}

	inline ApolloState* getApolloState() {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_OBJECT: {
				if (getObjectClass() != gmlClassOf.LuaState) return nullptr;
				// it would be faster to find a variable slot but that's a lot of work!
				auto rv = YYStructGetMember(this, "__ptr__");
				if (rv->kind != VALUE_PTR) return nullptr;
				return (ApolloState*)rv->ptr;
			};
			case VALUE_PTR:
				return (ApolloState*)ptr;
			default:
				return nullptr;
		}
	}
	inline bool tryGetApolloState(ApolloState** out) {
		switch (kind & MASK_KIND_RVALUE) {
			case VALUE_OBJECT: {
				if (getObjectClass() != gmlClassOf.LuaState) return false;
				// it would be faster to find a variable slot but that's a lot of work!
				auto rv = YYStructGetMember(this, "__ptr__");
				if (rv->kind != VALUE_PTR) return false;
				*out = (ApolloState*)rv->ptr;
				return true;
			};
			case VALUE_PTR:
				*out = (ApolloState*)ptr;
				return true;
			default:
				return false;
		}
	}
	bool tryGetLuaState(lua_State** out);
};

using YYResult = RValue;
struct YYRest {
	int length;
	RValue* items;
	inline RValue operator[] (int ind) const { return items[ind]; }
	inline RValue& operator[] (int ind) { return items[ind]; }
	// Ensures that the number does not exceed available items and that passing -1 uses all available items
	void procCount(int* count) {
		if (*count < 0 || *count > length) *count = length;
	}
	void procCountOffset(int* pCount, int* pOffset) {
		int offset = *pOffset;
		if (offset < 0) {
			*pOffset = offset = 0;
		} else if (offset > length) {
			*pOffset = offset = length;
		}
		int count = *pCount;
		if (count < 0) {
			*pCount = length - offset;
		} else {
			int maxCount = length - offset;
			if (count > maxCount) *pCount = maxCount;
		}
	}
};
using YYArrayItems = YYRest;

#define __YYArgCheck_trouble if (trouble) { YYError("Can't use " __FUNCTION__ " - Apollo has not been initialized."); return; }
#define __YYArgCheck_any __YYArgCheck_trouble
#define __YYArgCheck(argCount)\
	if (argc != argCount) {\
		__YYArgCheck_trouble;\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #argCount ", have %d", argc);\
		return;\
	}
#define __YYArgCheck_range(minArgs, maxArgs)\
	if (argc < minArgs || argc > maxArgs) {\
		__YYArgCheck_trouble;\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #minArgs ".." #maxArgs ", have %d", argc);\
		return;\
	}
#define __YYArgCheck_rest(minArgs)\
	if (argc < minArgs) {\
		__YYArgCheck_trouble;\
		YYError(__YYFUNCNAME__ " :: argument count mismatch - want " #minArgs " or more, have %d", argc);\
		return;\
	}
#define __YYArgError(name, want, i) {\
	YYError(__YYFUNCNAME__ " :: argument type mismatch for \"" name "\" - want " want ", have %s", KIND_NAME_RValue(&arg[i]));\
	return;\
}


#define __YYArg_YYRest(name, v, i) v = { argc - i, arg + i };
#define __YYArg_RValue_ptr(name, v, i) v = &arg[i];
#define __YYArg_int(name, v, i) if (!arg[i].tryGetInt(v)) __YYArgError(name, "an int", i);
#define __YYArg_int64(name, v, i) if (!arg[i].tryGetInt64(v)) __YYArgError(name, "an int64", i);
#define __YYArg_void_ptr(name, v, i) if (!arg[i].tryGetPtr(v)) __YYArgError(name, "a pointer", i);
#define __YYArg_const_char_ptr(name, v, i) if (!arg[i].tryGetString(v)) __YYArgError(name, "a string", i);
// semi-standard:
#define __YYArg_YYArrayItems(name, v, i) if (!arg[i].tryGetArrayItems(v.items, v.length)) __YYArgError(name, "an array", i);
// Lua:
#define __YYArg_ApolloState_ptr(name, v, i) if (!arg[i].tryGetApolloState(&v)) __YYArgError(name, "a Lua state", i);
#define __YYArg_lua_State_ptr(name, v, i) if (!arg[i].tryGetLuaState(&v)) __YYArgError(name, "a Lua state", i);


#define __YYResult_bool(v) result.kind = VALUE_BOOL; result.val = v;
#define __YYResult_int(v) result.kind = VALUE_REAL; result.val = v;
#define __YYResult_int64_t(v) result.kind = VALUE_INT64; result.v64 = v;
#define __YYResult_void_ptr(v) result.kind = VALUE_PTR; result.ptr = v;
#define __YYResult_const_char_ptr(v) YYCreateString(&result, v);

// TODO: add macros for project-specific types here
//{{NO_DEPENDENCIES}}
// Microsoft Visual C++ generated include file.
// Used by Apollo.rc

// Next default values for new objects
// 
#ifdef APSTUDIO_INVOKED
#ifndef APSTUDIO_READONLY_SYMBOLS
#define _APS_NEXT_RESOURCE_VALUE        101
#define _APS_NEXT_COMMAND_VALUE         40001
#define _APS_NEXT_CONTROL_VALUE         1001
#define _APS_NEXT_SYMED_VALUE           101
#endif
#endif
// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifdef _WINDOWS
	#include "targetver.h"
	
	#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
	#include <windows.h>
#endif

#define trace(...) { printf("[Apollo][%s:%d] ", __RELFILE__, __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

#include "apollo_state.h"
#include "gml_ext.h"
#include "gml_extm.h"
extern bool trouble;
#define trouble_check(_ret) if (trouble) return _ret;

// TODO: reference additional headers your program requires here#pragma once

// Including SDKDDKVer.h defines the highest available Windows platform.

// If you wish to build your application for a previous Windows platform, include WinSDKVer.h and
// set the _WIN32_WINNT macro to the platform you wish to support before including SDKDDKVer.h.

#include <SDKDDKVer.h>
#pragma once
//
// Copyright (C) 2020 Opera Norway AS. All rights reserved.
//
// This file is an original work developed by Opera.
//

#ifndef __YY__RUNNER_INTERFACE_H_
#define __YY__RUNNER_INTERFACE_H_

#include <stdint.h>

struct RValue;
class YYObjectBase;
class CInstance;
struct YYRunnerInterface;
struct HTTP_REQ_CONTEXT;
typedef int (*PFUNC_async)(HTTP_REQ_CONTEXT* _pContext, void* _pPayload, int* _pMap);
typedef void (*PFUNC_cleanup)(HTTP_REQ_CONTEXT* _pContext);
typedef void (*PFUNC_process)(HTTP_REQ_CONTEXT* _pContext);

typedef void (*TSetRunnerInterface)(const YYRunnerInterface* pRunnerInterface, size_t _functions_size);
typedef void (*TYYBuiltin)(RValue& Result, CInstance* selfinst, CInstance* otherinst, int argc, RValue* arg);
typedef long long int64;
typedef unsigned long long uint64;
typedef int32_t int32;
typedef uint32_t uint32;
typedef int16_t int16;
typedef uint16_t uint16;
typedef int8_t int8;
typedef uint8_t uint8;

#ifdef GDKEXTENSION_EXPORTS
enum class eBuffer_Format {
	Fixed = 0,
	Grow = 1,
	Wrap = 2,
	Fast = 3,
	VBuffer = 4,
	Network = 5,
};

class IBuffer;
#else
/* For eBuffer_Format */
#include <Files/Buffer/IBuffer.h>
#endif

typedef void* HYYMUTEX;
typedef void* HSPRITEASYNC;

struct YYRunnerInterface
{
	// basic interaction with the user
	void (*DebugConsoleOutput)(const char* fmt, ...); // hook to YYprintf
	void (*ReleaseConsoleOutput)(const char* fmt, ...);
	void (*ShowMessage)(const char* msg);

	// for printing error messages
	void (*YYError)(const char* _error, ...);

	// alloc, realloc and free
	void* (*YYAlloc)(int _size);
	void* (*YYRealloc)(void* pOriginal, int _newSize);
	void  (*YYFree)(const void* p);
	const char* (*YYStrDup)(const char* _pS);

	// yyget* functions for parsing arguments out of the arg index
	bool (*YYGetBool)(const RValue* _pBase, int _index);
	float (*YYGetFloat)(const RValue* _pBase, int _index);
	double (*YYGetReal)(const RValue* _pBase, int _index);
	int32_t(*YYGetInt32)(const RValue* _pBase, int _index);
	uint32_t(*YYGetUint32)(const RValue* _pBase, int _index);
	int64(*YYGetInt64)(const RValue* _pBase, int _index);
	void* (*YYGetPtr)(const RValue* _pBase, int _index);
	intptr_t(*YYGetPtrOrInt)(const RValue* _pBase, int _index);
	const char* (*YYGetString)(const RValue* _pBase, int _index);

	// typed get functions from a single rvalue
	bool (*BOOL_RValue)(const RValue* _pValue);
	double (*REAL_RValue)(const RValue* _pValue);
	void* (*PTR_RValue)(const RValue* _pValue);
	int64(*INT64_RValue)(const RValue* _pValue);
	int32_t(*INT32_RValue)(const RValue* _pValue);

	// calculate hash values from an RValue
	int (*HASH_RValue)(const RValue* _pValue);

	// copying, setting and getting RValue
	void (*SET_RValue)(RValue* _pDest, RValue* _pV, YYObjectBase* _pPropSelf, int _index);
	bool (*GET_RValue)(RValue* _pRet, RValue* _pV, YYObjectBase* _pPropSelf, int _index, bool fPrepareArray, bool fPartOfSet);
	void (*COPY_RValue)(RValue* _pDest, const RValue* _pSource);
	int (*KIND_RValue)(const RValue* _pValue);
	void (*FREE_RValue)(RValue* _pValue);
	void (*YYCreateString)(RValue* _pVal, const char* _pS);

	void (*YYCreateArray)(RValue* pRValue, int n_values, const double* values);

	// finding and runnine user scripts from name
	int (*Script_Find_Id)(const char* name);
	bool (*Script_Perform)(int ind, CInstance* selfinst, CInstance* otherinst, int argc, RValue* res, RValue* arg);

	// finding builtin functions
	bool  (*Code_Function_Find)(const char* name, int* ind);

	// http functions
	void (*HTTP_Get)(const char* _pFilename, int _type, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV);
	void (*HTTP_Post)(const char* _pFilename, const char* _pPost, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV);
	void (*HTTP_Request)(const char* _url, const char* _method, const char* _headers, const char* _pBody, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV, int _contentLength);

	// sprite loading helper functions
	int (*ASYNCFunc_SpriteAdd)(HTTP_REQ_CONTEXT* _pContext, void* _p, int* _pMap);
	void (*ASYNCFunc_SpriteCleanup)(HTTP_REQ_CONTEXT* _pContext);
	HSPRITEASYNC(*CreateSpriteAsync)(int* _pSpriteIndex, int _xOrig, int _yOrig, int _numImages, int _flags);

	// timing
	int64(*Timing_Time)(void);
	void (*Timing_Sleep)(int64 slp, bool precise);

	// mutex handling
	HYYMUTEX(*YYMutexCreate)(const char* _name);
	void (*YYMutexDestroy)(HYYMUTEX hMutex);
	void (*YYMutexLock)(HYYMUTEX hMutex);
	void (*YYMutexUnlock)(HYYMUTEX hMutex);

	// ds map manipulation for 
	void (*CreateAsyncEventWithDSMap)(int _map, int _event);
	void (*CreateAsyncEventWithDSMapAndBuffer)(int _map, int _buffer, int _event);
	int (*CreateDsMap)(int _num, ...);

	bool (*DsMapAddDouble)(int _index, const char* _pKey, double value);
	bool (*DsMapAddString)(int _index, const char* _pKey, const char* pVal);
	bool (*DsMapAddInt64)(int _index, const char* _pKey, int64 value);

	// buffer access
	bool (*BufferGetContent)(int _index, void** _ppData, int* _pDataSize);
	int (*BufferWriteContent)(int _index, int _dest_offset, const void* _pSrcMem, int _size, bool _grow, bool _wrap);
	int (*CreateBuffer)(int _size, enum eBuffer_Format _bf, int _alignment);

	// variables
	volatile bool* pLiveConnection;
	int* pHTTP_ID;

	int (*DsListCreate)();
	void (*DsMapAddList)(int _dsMap, const char* _key, int _listIndex);
	void (*DsListAddMap)(int _dsList, int _mapIndex);
	void (*DsMapClear)(int _dsMap);
	void (*DsListClear)(int _dsList);

	bool (*BundleFileExists)(const char* _pszFileName);
	bool (*BundleFileName)(char* _name, int _size, const char* _pszFileName);
	bool (*SaveFileExists)(const char* _pszFileName);
	bool (*SaveFileName)(char* _name, int _size, const char* _pszFileName);

	bool (*Base64Encode)(const void* input_buf, size_t input_len, void* output_buf, size_t output_len);

	void (*DsListAddInt64)(int _dsList, int64 _value);

	void (*AddDirectoryToBundleWhitelist)(const char* _pszFilename);
	void (*AddFileToBundleWhitelist)(const char* _pszFilename);
	void (*AddDirectoryToSaveWhitelist)(const char* _pszFilename);
	void (*AddFileToSaveWhitelist)(const char* _pszFilename);

	const char* (*KIND_NAME_RValue)(const RValue* _pV);

	void (*DsMapAddBool)(int _index, const char* _pKey, bool value);
	void (*DsMapAddRValue)(int _index, const char* _pKey, RValue* value);
	void (*DestroyDsMap)(int _index);

	void (*StructCreate)(RValue* _pStruct);
	void (*StructAddBool)(RValue* _pStruct, const char* _pKey, bool _value);
	void (*StructAddDouble)(RValue* _pStruct, const char* _pKey, double _value);
	void (*StructAddInt)(RValue* _pStruct, const char* _pKey, int _value);
	void (*StructAddRValue)(RValue* _pStruct, const char* _pKey, RValue* _pValue);
	void (*StructAddString)(RValue* _pStruct, const char* _pKey, const char* _pValue);

	bool (*WhitelistIsDirectoryIn)(const char* _pszDirectory);
	bool (*WhiteListIsFilenameIn)(const char* _pszFilename);
	void (*WhiteListAddTo)(const char* _pszFilename, bool _bIsDir);
	bool (*DirExists)(const char* filename);
	IBuffer* (*BufferGetFromGML)(int ind);
	int (*BufferTELL)(IBuffer* buff);
	unsigned char* (*BufferGet)(IBuffer* buff);
	const char* (*FilePrePend)(void);

	void (*StructAddInt32)(RValue* _pStruct, const char* _pKey, int32 _value);
	void (*StructAddInt64)(RValue* _pStruct, const char* _pKey, int64 _value);
	RValue* (*StructGetMember)(RValue* _pStruct, const char* _pKey);

	/**
	 * @brief Query the keys in a struct.
	 *
	 * @param _pStruct  Pointer to a VALUE_OBJECT RValue.
	 * @param _keys     Pointer to an array of const char* pointers to receive the names.
	 * @param _count    Length of _keys (in elements) on input, number filled on output.
	 *
	 * @return Total number of keys in the struct.
	 *
	 * NOTE: The strings in _keys are owned by the runner. You do not need to free them, however
	 * you should make a copy if you intend to keep them around as the runner may invalidate them
	 * in the future when performing variable modifications.
	 *
	 * Usage example:
	 *
	 *    // Get total number of keys in struct
	 *    int num_keys = YYRunnerInterface_p->StructGetKeys(struct_rvalue, NULL, NULL);
	 *
	 *    // Fetch keys from struct
	 *    std::vector<const char*> keys(num_keys);
	 *    YYRunnerInterface_p->StructGetKeys(struct_rvalue, keys.data(), &num_keys);
	 *
	 *    // Loop over struct members
	 *    for(int i = 0; i < num_keys; ++i)
	 *    {
	 *        RValue *member = YYRunnerInterface_p->StructGetMember(struct_rvalue, keys[i]);
	 *        ...
	 *    }
	*/
	int (*StructGetKeys)(RValue* _pStruct, const char** _keys, int* _count);

	RValue* (*YYGetStruct)(RValue* _pBase, int _index);



	void (*extOptGetRValue)(RValue& result, const char* _ext, const  char* _opt);
	const char* (*extOptGetString)(const char* _ext, const  char* _opt);
	double (*extOptGetReal)(const char* _ext, const char* _opt);
};


#if defined(__YYDEFINE_EXTENSION_FUNCTIONS__)
extern YYRunnerInterface* g_pYYRunnerInterface;

// basic interaction with the user
#define DebugConsoleOutput(fmt, ...) g_pYYRunnerInterface->DebugConsoleOutput(fmt, __VA_ARGS__)
#define ReleaseConsoleOutput(fmt, ...) g_pYYRunnerInterface->ReleaseConsoleOutput(fmt, __VA_ARGS__)
inline void ShowMessage(const char* msg) { g_pYYRunnerInterface->ShowMessage(msg); }

// for printing error messages
#define YYError(_error, ...)				g_pYYRunnerInterface->YYError( _error, __VA_ARGS__ )

// alloc, realloc and free
inline void* YYAlloc(int _size) { return g_pYYRunnerInterface->YYAlloc(_size); }
inline void* YYRealloc(void* pOriginal, int _newSize) { return g_pYYRunnerInterface->YYRealloc(pOriginal, _newSize); }
inline void  YYFree(const void* p) { g_pYYRunnerInterface->YYFree(p); }
inline const char* YYStrDup(const char* _pS) { return g_pYYRunnerInterface->YYStrDup(_pS); }

// yyget* functions for parsing arguments out of the arg index
inline bool YYGetBool(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetBool(_pBase, _index); }
inline float YYGetFloat(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetFloat(_pBase, _index); }
inline double YYGetReal(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetReal(_pBase, _index); }
inline int32_t YYGetInt32(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetInt32(_pBase, _index); }
inline uint32_t YYGetUint32(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetUint32(_pBase, _index); }
inline int64 YYGetInt64(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetInt64(_pBase, _index); }
inline void* YYGetPtr(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetPtr(_pBase, _index); }
inline intptr_t YYGetPtrOrInt(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetPtrOrInt(_pBase, _index); }
inline const char* YYGetString(const RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetString(_pBase, _index); }
inline RValue* YYGetStruct(RValue* _pBase, int _index) { return g_pYYRunnerInterface->YYGetStruct(_pBase, _index); }

// typed get functions from a single rvalue
inline bool BOOL_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->BOOL_RValue(_pValue); }
inline double REAL_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->REAL_RValue(_pValue); }
inline void* PTR_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->PTR_RValue(_pValue); }
inline int64 INT64_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->INT64_RValue(_pValue); }
inline int32_t INT32_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->INT32_RValue(_pValue); }

// calculate hash values from an RValue
inline int HASH_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->HASH_RValue(_pValue); }

// copying, setting and getting RValue
inline void SET_RValue(RValue* _pDest, RValue* _pV, YYObjectBase* _pPropSelf, int _index) { return g_pYYRunnerInterface->SET_RValue(_pDest, _pV, _pPropSelf, _index); }
inline bool GET_RValue(RValue* _pRet, RValue* _pV, YYObjectBase* _pPropSelf, int _index, bool fPrepareArray = false, bool fPartOfSet = false) { return g_pYYRunnerInterface->GET_RValue(_pRet, _pV, _pPropSelf, _index, fPrepareArray, fPartOfSet); }
inline void COPY_RValue(RValue* _pDest, const RValue* _pSource) { g_pYYRunnerInterface->COPY_RValue(_pDest, _pSource); }
inline int KIND_RValue(const RValue* _pValue) { return g_pYYRunnerInterface->KIND_RValue(_pValue); }
inline void FREE_RValue(RValue* _pValue) { return g_pYYRunnerInterface->FREE_RValue(_pValue); }
inline void YYCreateString(RValue* _pVal, const char* _pS) { g_pYYRunnerInterface->YYCreateString(_pVal, _pS); }
inline const char* KIND_NAME_RValue(const RValue* _pV) { return g_pYYRunnerInterface->KIND_NAME_RValue(_pV); }

inline void YYCreateArray(RValue* pRValue, int n_values = 0, const double* values = NULL) { g_pYYRunnerInterface->YYCreateArray(pRValue, n_values, values); }

// finding and runnine user scripts from name
inline int Script_Find_Id(char* name) { return g_pYYRunnerInterface->Script_Find_Id(name); }
inline bool Script_Perform(int ind, CInstance* selfinst, CInstance* otherinst, int argc, RValue* res, RValue* arg) {
	return g_pYYRunnerInterface->Script_Perform(ind, selfinst, otherinst, argc, res, arg);
}

// finding builtin functions
inline bool  Code_Function_Find(char* name, int* ind) { return g_pYYRunnerInterface->Code_Function_Find(name, ind); }

// Http function
inline void HTTP_Get(const char* _pFilename, int _type, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV) { g_pYYRunnerInterface->HTTP_Get(_pFilename, _type, _async, _cleanup, _pV); }
inline void HTTP_Post(const char* _pFilename, const char* _pPost, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV) { g_pYYRunnerInterface->HTTP_Post(_pFilename, _pPost, _async, _cleanup, _pV); }
inline void HTTP_Request(const char* _url, const char* _method, const char* _headers, const char* _pBody, PFUNC_async _async, PFUNC_cleanup _cleanup, void* _pV, int _contentLength = -1) {
	g_pYYRunnerInterface->HTTP_Request(_url, _method, _headers, _pBody, _async, _cleanup, _pV, _contentLength);
} // end HTTP_Request

// sprite async loading
inline HSPRITEASYNC CreateSpriteAsync(int* _pSpriteIndex, int _xOrig, int _yOrig, int _numImages, int _flags) {
	return g_pYYRunnerInterface->CreateSpriteAsync(_pSpriteIndex, _xOrig, _yOrig, _numImages, _flags);
} // end CreateSpriteAsync


// timing
inline int64 Timing_Time(void) { return g_pYYRunnerInterface->Timing_Time(); }
inline void Timing_Sleep(int64 slp, bool precise = false) { g_pYYRunnerInterface->Timing_Sleep(slp, precise); }

// mutex functions
inline HYYMUTEX YYMutexCreate(const char* _name) { return g_pYYRunnerInterface->YYMutexCreate(_name); }
inline void YYMutexDestroy(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexDestroy(hMutex); }
inline void YYMutexLock(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexLock(hMutex); }
inline void YYMutexUnlock(HYYMUTEX hMutex) { g_pYYRunnerInterface->YYMutexUnlock(hMutex); }

// ds map manipulation for 
inline void CreateAsyncEventWithDSMap(int _map, int _event) { return g_pYYRunnerInterface->CreateAsyncEventWithDSMap(_map, _event); }
inline void CreateAsyncEventWithDSMapAndBuffer(int _map, int _buffer, int _event) { return g_pYYRunnerInterface->CreateAsyncEventWithDSMapAndBuffer(_map, _buffer, _event); }
#define CreateDsMap(_num, ...) g_pYYRunnerInterface->CreateDsMap( _num, __VA_ARGS__ )

inline bool DsMapAddDouble(int _index, const char* _pKey, double value) { return g_pYYRunnerInterface->DsMapAddDouble(_index, _pKey, value); }
inline bool DsMapAddString(int _index, const char* _pKey, const char* pVal) { return g_pYYRunnerInterface->DsMapAddString(_index, _pKey, pVal); }
inline bool DsMapAddInt64(int _index, const char* _pKey, int64 value) { return g_pYYRunnerInterface->DsMapAddInt64(_index, _pKey, value); }
inline void DsMapAddList(int _dsMap, const char* _pKey, int _listIndex) { return g_pYYRunnerInterface->DsMapAddList(_dsMap, _pKey, _listIndex); }
inline void DsMapAddBool(int _dsMap, const char* _pKey, bool value) { return g_pYYRunnerInterface->DsMapAddBool(_dsMap, _pKey, value); }
inline void DsMapAddRValue(int _dsMap, const char* _pKey, RValue* value) { return g_pYYRunnerInterface->DsMapAddRValue(_dsMap, _pKey, value); }
inline void DsMapClear(int _index) { return g_pYYRunnerInterface->DsMapClear(_index); }
inline void DestroyDsMap(int _index) { g_pYYRunnerInterface->DestroyDsMap(_index); }

inline int DsListCreate() { return g_pYYRunnerInterface->DsListCreate(); }
inline void DsListAddMap(int _dsList, int _mapIndex) { return g_pYYRunnerInterface->DsListAddMap(_dsList, _mapIndex); }
inline void DsListClear(int _dsList) { return g_pYYRunnerInterface->DsListClear(_dsList); }

// buffer access
inline bool BufferGetContent(int _index, void** _ppData, int* _pDataSize) { return g_pYYRunnerInterface->BufferGetContent(_index, _ppData, _pDataSize); }
inline int BufferWriteContent(int _index, int _dest_offset, const void* _pSrcMem, int _size, bool _grow = false, bool _wrap = false) { return g_pYYRunnerInterface->BufferWriteContent(_index, _dest_offset, _pSrcMem, _size, _grow, _wrap); }
inline int CreateBuffer(int _size, enum eBuffer_Format _bf, int _alignment) { return g_pYYRunnerInterface->CreateBuffer(_size, _bf, _alignment); }

inline bool Base64Encode(const void* input_buf, size_t input_len, void* output_buf, size_t output_len) { g_pYYRunnerInterface->Base64Encode(input_buf, input_len, output_buf, output_len); }

inline void AddDirectoryToBundleWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddDirectoryToBundleWhitelist(_pszFilename); }
inline void AddFileToBundleWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddFileToBundleWhitelist(_pszFilename); }
inline void AddDirectoryToSaveWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddDirectoryToSaveWhitelist(_pszFilename); }
inline void AddFileToSaveWhitelist(const char* _pszFilename) { g_pYYRunnerInterface->AddFileToSaveWhitelist(_pszFilename); }

inline void YYStructCreate(RValue* _pStruct) { g_pYYRunnerInterface->StructCreate(_pStruct); }
inline void YYStructAddBool(RValue* _pStruct, const char* _pKey, double _value) { return g_pYYRunnerInterface->StructAddBool(_pStruct, _pKey, _value); }
inline void YYStructAddDouble(RValue* _pStruct, const char* _pKey, double _value) { return g_pYYRunnerInterface->StructAddDouble(_pStruct, _pKey, _value); }
inline void YYStructAddInt(RValue* _pStruct, const char* _pKey, int _value) { return g_pYYRunnerInterface->StructAddInt(_pStruct, _pKey, _value); }
inline void YYStructAddRValue(RValue* _pStruct, const char* _pKey, RValue* _pValue) { return g_pYYRunnerInterface->StructAddRValue(_pStruct, _pKey, _pValue); }
inline void YYStructAddString(RValue* _pStruct, const char* _pKey, const char* _pValue) { return g_pYYRunnerInterface->StructAddString(_pStruct, _pKey, _pValue); }

inline bool WhitelistIsDirectoryIn(const char* _pszDirectory) { return g_pYYRunnerInterface->WhitelistIsDirectoryIn(_pszDirectory); }
inline bool WhiteListIsFilenameIn(const char* _pszFilename) { return g_pYYRunnerInterface->WhiteListIsFilenameIn(_pszFilename); }
inline void WhiteListAddTo(const char* _pszFilename, bool _bIsDir) { return g_pYYRunnerInterface->WhiteListAddTo(_pszFilename, _bIsDir); }
inline bool DirExists(const char* filename) { return g_pYYRunnerInterface->DirExists(filename); }

inline IBuffer* BufferGetFromGML(int ind) { return g_pYYRunnerInterface->BufferGetFromGML(ind); }
inline int BufferTELL(IBuffer* buff) { return g_pYYRunnerInterface->BufferTELL(buff); }
inline unsigned char* BufferGet(IBuffer* buff) { return g_pYYRunnerInterface->BufferGet(buff); }
inline const char* FilePrePend(void) { return g_pYYRunnerInterface->FilePrePend(); }

inline void YYStructAddInt32(RValue* _pStruct, const char* _pKey, int32 _value) { return g_pYYRunnerInterface->StructAddInt32(_pStruct, _pKey, _value); }
inline void YYStructAddInt64(RValue* _pStruct, const char* _pKey, int64 _value) { return g_pYYRunnerInterface->StructAddInt64(_pStruct, _pKey, _value); }
inline RValue* YYStructGetMember(RValue* _pStruct, const char* _pKey) { return g_pYYRunnerInterface->StructGetMember(_pStruct, _pKey); }
inline int YYStructGetKeys(RValue* _pStruct, const char** _keys, int* _count) { return g_pYYRunnerInterface->StructGetKeys(_pStruct, _keys, _count); }


inline void extOptGetRValue(RValue& result, const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetRValue(result, _ext, _opt); };
inline const char* extOptGetString(const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetString(_ext, _opt); }
inline double extOptGetReal(const char* _ext, const char* _opt) { return g_pYYRunnerInterface->extOptGetReal(_ext, _opt); };

#define g_LiveConnection	(*g_pYYRunnerInterface->pLiveConnection)
#define g_HTTP_ID			(*g_pYYRunnerInterface->pHTTP_ID)


#endif


/*
#define YY_HAS_FUNCTION(interface, interface_size, function) \
	(interface_size >= (offsetof(GameMaker_RunnerInterface, function) + sizeof(GameMaker_RunnerInterface::function)) && interface->function != NULL)

#define YY_REQUIRE_FUNCTION(interface, interface_size, function) \
	if(!GameMaker_HasFunction(interface, interface_size, function)) \
	{ \
		interface->DebugConsoleOutput("Required function missing: %s\n", #function); \
		interface->DebugConsoleOutput("This extension may not be compatible with this version of GameMaker\n"); \
		return false; \
	}
*/

#ifndef __Action_Class_H__
const int ARG_CONSTANT = -1;           // Argument kinds
const int ARG_EXPRESSION = 0;
const int ARG_STRING = 1;
const int ARG_STRINGEXP = 2;
const int ARG_BOOLEAN = 3;
const int ARG_MENU = 4;
const int ARG_SPRITE = 5;
const int ARG_SOUND = 6;
const int ARG_BACKGROUND = 7;
const int ARG_PATH = 8;
const int ARG_SCRIPT = 9;
const int ARG_OBJECT = 10;
const int ARG_ROOM = 11;
const int ARG_FONTR = 12;
const int ARG_COLOR = 13;
const int ARG_TIMELINE = 14;
const int ARG_FONT = 15;
#endif

#endif
#include "stdafx.h"
#include "apollo_shared.h"

namespace Apollo {
	ApolloState* getState(lua_State* L) {
		lua_pushstring(L, "apolloState");
		lua_gettable(L, LUA_REGISTRYINDEX);
		auto ptr = (ApolloState**)luaL_checkudata(L, -1, "ApolloState");
		lua_pop(L, 1);
		return ptr ? *ptr : nullptr;
	}
}

void apollo_interop_init(ApolloState* wrapState, lua_State* L);
dllgm void* lua_state_create_raw(RValue* gmlState, RValue* destructor) {
	auto L = luaL_newstate();
	auto wrapState = new ApolloState(L, nullptr);
	wrapState->selfValue = YYStructGetMember(gmlState, "__self__");
	wrapState->callArgs = YYStructGetMember(gmlState, "__call_args");
	YYStructAddRValue(gmlState, "@@Dispose@@", destructor);
	luaL_openlibs(L);
	apollo_interop_init(wrapState, L);
	return wrapState;
}

dllm void lua_state_destroy_raw(YYFuncArgs) {
	auto state = arg[0].getApolloState();
	if (state) delete state;
}

dllgm void lua_add_code(YYResult& result, lua_State* L, const char* code) {
	dllm_handle_lua_error(luaL_loadstring(L, code) || lua_pcall(L, 0, 1, 0));
	Apollo::popLuaStackValue(&result, L);
}

dllgm void lua_add_code_multret(YYResult& result, lua_State* L, const char* code) {
	dllm_handle_lua_error(luaL_loadstring(L, code) || lua_pcall(L, 0, LUA_MULTRET, 0));
	Apollo::popLuaStackValuesAsArray(&result, L);
}

dllgm bool is_lua_ref(RValue* val) {
	if ((val->kind & MASK_KIND_RVALUE) == VALUE_OBJECT) {
		return gmlClassOf.isLuaRef(val->getObjectClass());
	} else return false;
}#include "stdafx.h"
#include "apollo_shared.h"

namespace Apollo {
	static int64_t getUID(lua_State* L, int ind) {
		auto ptr = (int64_t*)luaL_testudata(L, ind, "GmlArray");
		return ptr ? *ptr : 0;
	}
	template<size_t argc> static void setupCall(RValue(&args)[argc], lua_State* L, int script_id) {
		auto state = Apollo::getState(L);
		auto uid = getUID(L, 1);
		static_assert(argc >= 3, "Not enough arguments!");
		args[0].setScriptID(script_id);
		args[1].setTo(state->selfValue);
		args[2].setInt64(uid);
	}
	static int createGmlArrayUD(lua_State* L) {
		auto uid = lua_tointeger(L, 1);
		auto ptr = lua_newuserdata_t<int64_t>(L);
		*ptr = uid;
		luaL_getmetatable(L, "GmlArray");
		lua_setmetatable(L, -2);
		return 1;
	}
	static int __gc(lua_State* L) {
		static RValue args[3], result;
		setupCall(args, L, gml_Script.lua_gml_ref_free);
		GML::script_execute_def(result, args);
		args[1].free();
		return 0;
	}
	static int __len(lua_State* L) {
		static RValue args[3], result;
		setupCall(args, L, gml_Script.lua_gml_ref_get_length);
		GML::script_execute_def_for(result, args, L);
		args[1].free();
		Apollo::pushGMLtoLuaStack(&result, L);
		return 1;
	}
	static int __index(lua_State* L) {
		static RValue args[4], result;
		setupCall(args, L, gml_Script.lua_gml_ref_get_index);
		Apollo::luaToGML(&args[3], L, 2);
		GML::script_execute_def_for(result, args, L);
		args[1].free();
		args[3].free();
		Apollo::pushGMLtoLuaStack(&result, L);
		return 1;
	}
	static int __newindex(lua_State* L) {
		static RValue args[5], result;
		setupCall(args, L, gml_Script.lua_gml_ref_set_index);
		Apollo::luaToGML(&args[3], L, 2);
		Apollo::luaToGML(&args[4], L, 3);
		GML::script_execute_def_for(result, args, L);
		args[1].free();
		args[3].free();
		args[4].free();
		return 0;
	}
	static luaL_Reg metaPairs[] = {
		{ "__gc", __gc },
		{ "__len", __len },
		{ "__index", __index },
		{ "__newindex", __newindex },
		{ 0, 0 }
	};
	void initArrayRef(lua_State* L) {
		luaL_newmetatable(L, "GmlArray");
		luaL_setfuncs(L, metaPairs, 0);
		lua_pop(L, 1);

		lua_pushcfunction(L, createGmlArrayUD);
		lua_setglobal(L, "__apollo_tmp");

		luaL_dostring_trace(L, "lua_array_ref", R"lua(
(function()
	local _create_udata = __apollo_tmp
	__apollo_tmp = nil
	
	local _uid_to_udata = setmetatable({}, { __mode = "v" })
	__apollo_get_gml_array_udata = function(uid)
		local ud = _uid_to_udata[uid]
		if (ud == nil) then
			ud = _create_udata(uid)
			_uid_to_udata[uid] = ud
		end
		return ud
	end
end)()
)lua")
	}
}#include "stdafx.h"
#include "apollo_shared.h"

namespace Apollo {
	void luaToGML(RValue* result, lua_State* L, int idx) {
		auto t = lua_type(L, idx);
		const auto refMask = (1 << LUA_TTABLE)
			| (1 << LUA_TFUNCTION)
			| (1 << LUA_TUSERDATA)
			| (1 << LUA_TLIGHTUSERDATA)
			| (1 << LUA_TTHREAD);
		if ((refMask & (1 << t)) != 0) {
			Apollo::createLuaRef(result, L, idx);
			return;
		}
		switch (lua_type(L, idx)) {
			case LUA_TNUMBER:
				if (lua_isinteger(L, idx)) {
					result->kind = VALUE_INT64;
					result->v64 = lua_tointeger(L, idx);
				} else {
					result->kind = VALUE_REAL;
					result->val = lua_tonumber(L, idx);
				}
				break;
			case LUA_TBOOLEAN:
				result->kind = VALUE_BOOL;
				result->val = lua_toboolean(L, idx);
				break;
			case LUA_TSTRING:
				YYCreateString(result, lua_tostring(L, idx));
				break;
			default:
				result->kind = VALUE_UNDEFINED;
				result->ptr = nullptr;
				break;
		}
	}
	void popLuaStackValue(RValue* result, lua_State* L) {
		luaToGML(result, L, -1);
		lua_pop(L, 1);
	}
	void popLuaStackValuesAsArray(RValue* result, lua_State* L, int count) {
		//trace("pop start: %s", apollo_print_stack(L));
		if (count == LUA_MULTRET) count = lua_gettop(L);

		YYCreateEmptyArray(result, count);

		auto items = result->getArrayItems();
		for (int i = 0; i < count; i++) {
			luaToGML(&items[i], L, i + 1);
		}
		lua_pop(L, count);
	}
	void pushGMLtoLuaStack(RValue* value, lua_State* L) {
		switch (value->kind) {
			case VALUE_REAL:
				lua_pushnumber(L, value->val);
				break;
			case VALUE_INT32: case VALUE_REF:
				lua_pushinteger(L, value->v32);
				break;
			case VALUE_INT64:
				lua_pushinteger(L, value->v64);
				break;
			case VALUE_BOOL:
				lua_pushboolean(L, (int)value->val);
				break;
			case VALUE_STRING:
				lua_pushstring(L, value->getString());
				break;
			case VALUE_OBJECT: {
				auto isLuaRef = gmlClassOf.isLuaRef(value->getObjectClass());
				auto isCrossRef = isLuaRef && value->getStructMember("__state__")->ptr != Apollo::getState(L)->selfValue->ptr;
				if (isLuaRef && !isCrossRef) {
					// passing a Lua reference back to Lua?
					auto uid = YYStructGetMember(value, "__uid__")->getInt64();
					lua_getglobal(L, "__apollo_uid_to_ref");
					lua_pushinteger(L, uid);
					lua_pcall(L, 1, 1, 0);
					break;
				}
				static RValue args[3], result;
				args[0].setScriptID(gml_Script.lua_gml_ref_to_uid);
				args[1].setTo(Apollo::getState(L)->selfValue);
				args[2].setTo(value);
				GML::script_execute_def(result, args);
				args[1].free();
				args[2].free();
				lua_getglobal(L, "__apollo_get_gml_struct_udata");
				lua_pushinteger(L, result.getInt64());
				lua_pushboolean(L, isCrossRef);
				if (lua_pcall(L, 2, 1, 0)) {
					Apollo::handleLuaError(L);
					lua_pushnil(L);
				}
				break;
			}
			case VALUE_ARRAY: {
				static RValue args[3], result;
				args[0].setScriptID(gml_Script.lua_gml_ref_to_uid);
				args[1].setTo(Apollo::getState(L)->selfValue);
				args[2].setTo(value);
				GML::script_execute_def(result, args);
				args[1].free();
				args[2].free();
				lua_getglobal(L, "__apollo_get_gml_array_udata");
				lua_pushinteger(L, result.getInt64());
				if (lua_pcall(L, 1, 1, 0)) {
					Apollo::handleLuaError(L);
					lua_pushnil(L);
				}
				break;
			}
			default:
				lua_pushnil(L);
				break;
		}
	}
}#include "stdafx.h"
#include "apollo_shared.h"

dllgm void lua_global_get(YYResult& result, lua_State* L, const char* name) {
	lua_getglobal(L, name);
	Apollo::popLuaStackValue(&result, L);
}

dllgm void lua_global_set(lua_State* L, const char* name, RValue* value) {
	Apollo::pushGMLtoLuaStack(value, L);
	lua_setglobal(L, name);
}

dllgm void lua_global_call(YYResult& result, lua_State* L, const char* fname, YYRest args) {
	lua_getglobal(L, fname);
	for (int i = 0; i < args.length; i++) Apollo::pushGMLtoLuaStack(&args[i], L);
	dllm_handle_lua_error(lua_pcall(L, args.length, 1, 0));
	Apollo::popLuaStackValue(&result, L);
}

dllgm void lua_global_call_ext(YYResult& result, lua_State* L, const char* fname,
	YYArrayItems argArray, int offset = 0, int numArgs = -1
) {
	lua_getglobal(L, fname);
	argArray.procCountOffset(&numArgs, &offset);
	for (int i = offset; i < numArgs; i++) Apollo::pushGMLtoLuaStack(&argArray[i], L);
	dllm_handle_lua_error(lua_pcall(L, numArgs, 1, 0));
	Apollo::popLuaStackValue(&result, L);
}

dllgm void lua_global_call_multret(YYResult& result, lua_State* L, const char* fname, YYRest args) {
	lua_getglobal(L, fname);
	for (int i = 0; i < args.length; i++) Apollo::pushGMLtoLuaStack(&args[i], L);
	dllm_handle_lua_error(lua_pcall(L, args.length, LUA_MULTRET, 0));
	Apollo::popLuaStackValuesAsArray(&result, L);
}

dllgm void lua_global_call_ext_multret(YYResult& result, lua_State* L, const char* fname,
	YYArrayItems argArray, int offset = 0, int numArgs = -1
) {
	lua_getglobal(L, fname);
	argArray.procCountOffset(&numArgs, &offset);
	for (int i = offset; i < numArgs; i++) Apollo::pushGMLtoLuaStack(&argArray[i], L);
	dllm_handle_lua_error(lua_pcall(L, numArgs, LUA_MULTRET, 0));
	Apollo::popLuaStackValuesAsArray(&result, L);
}
#include "stdafx.h"
#include "apollo_shared.h"
#include <string>
#define __RELFILE__ "apollo_init.cpp"
#ifdef _WINDOWS
//#define _APOLLO_MEMCHECK
#endif

bool trouble = true;

static bool canAccessMemory(const void* base, size_t size) {
	#ifdef _APOLLO_MEMCHECK
	const auto pmask = PAGE_READONLY | PAGE_READWRITE | PAGE_WRITECOPY
		| PAGE_EXECUTE | PAGE_EXECUTE_READ | PAGE_EXECUTE_READWRITE | PAGE_EXECUTE_WRITECOPY;
	::MEMORY_BASIC_INFORMATION mbi{};
	size_t steps = size > 0 ? 2 : 1;
	for (auto step = 0u; step < steps; step++) {
		const void* addr = ((uint8_t*)base) + step * (size - 1);
		if (!VirtualQuery(addr, &mbi, sizeof mbi)) return false;
		if (mbi.State != MEM_COMMIT) return false;
		if ((mbi.Protect & PAGE_GUARD) != 0) return false;
		if ((mbi.Protect & pmask) == 0) return false;
	}
	#endif
	return true;
}

static int findCScriptRefOffset(void* _fptr_1, void* _fptr_2, void* _mptr_1, void* _mptr_2) {
	auto f1 = (void**)_fptr_1;
	auto f2 = (void**)_fptr_2;
	auto f3 = (void**)_mptr_1;
	auto f4 = (void**)_mptr_2;
	void** fx[] = { f1, f2, f3, f4 };
	for (auto i = 10u; i < 24; i++) {
		auto step = 0u;
		for (; step < 2; step++) {
			auto fi = fx[step];

			// should be NULL, <addr>, NULL:
			if (fi[i - 1] != nullptr) break;
			if (fi[i] == nullptr) break;
			if (fi[i + 1] != nullptr) break;
			// and the method pointers shouldn't have a function in them:
			auto mi = fx[step + 2];
			if (mi[i] != nullptr) break;
}
		if (step < 2u) continue;

		// destination address must match:
		auto dest = f1[i];
		if (dest != f2[i]) continue;

		return (int)(sizeof(void*) * i);
	}
	return -1;
}

dllx double apollo_init_1(void* _fptr_1, void* _fptr_2, void* _mptr_1, void* _mptr_2) {
	auto ofs = findCScriptRefOffset(_fptr_1, _fptr_2, _mptr_1, _mptr_2);
	if (ofs < 0) return -1;
	gmlOffsets.CScriptRef.cppFunc = ofs;

	// both CWeakRef and CScriptRef inherit from YYObjectBase;
	// in CScriptRef, the three pointers are the first non-inherited members.
	// in CWeakRef, the destination pointer is the first non-inherited member.
	gmlOffsets.CWeakRef.weakRef = ofs - sizeof(void*);

	// we'll check if it's a 2023.8+ array layout in the function below:
	gmlOffsets.RefDynamicArrayOfRValue.items = gmlOffsets.CWeakRef.weakRef.offset + sizeof(int) * 2;
	gmlOffsets.RefDynamicArrayOfRValue.length = gmlOffsets.RefDynamicArrayOfRValue.items.offset + sizeof(void*) + sizeof(int64_t) + sizeof(int);
	return 1;
}

dllgm void apollo_init_array(RValue* a2, RValue* a3, RValue* a4) {
	// at first arrays were a little struct
	// with introduction of GC, arrays were made into a collectable object, inherting from YYObjectBase
	// now arrays are a little struct again, and they've got a pointer to YYObjectBase (probably used *only* for GC)
	// the new layout is like this:
	/*
	struct RefDynamicArrayOfRValue {
		YYObjectBase* gcThing;
		RValue* items;
		int64 copyOnWriteStuff;
		int refCount;
		int mystery1;
		int mystery2;
		int length;
	}
	*/
	FieldOffset<int> magicLength = sizeof(void*) * 2 + sizeof(int64) + sizeof(int) * 3;
	if (magicLength.read(a2->ptr) == 2 && magicLength.read(a3->ptr) == 3 && magicLength.read(a4->ptr) == 4) {
		// so if what we've passed seems to be using that layout, 
		gmlOffsets.RefDynamicArrayOfRValue.items.offset = sizeof(void*);
		gmlOffsets.RefDynamicArrayOfRValue.length = magicLength;
	}
}

constexpr char gml_Script_[] = "gml_Script_";
dllx double apollo_init_2(uint8_t* _c1, uint8_t* _c2) {
	auto c1 = (void**)_c1;
	auto c2 = (void**)_c2;
	void** cx[] = { c1, c2 };
	#ifdef _APOLLO_MEMCHECK
	::MEMORY_BASIC_INFORMATION mbi{};
	const auto pmask = PAGE_READONLY | PAGE_READWRITE | PAGE_WRITECOPY;
	#endif
	for (auto i = 1; i < 10; i++) {
		auto step = 0u;
		for (; step < 2; step++) {
			auto ci = cx[step];
			if (!canAccessMemory(ci + i, sizeof(void*))) return -1;
			if (c1[i] == nullptr) break;
			if (!canAccessMemory(ci[i], sizeof(gml_Script_))) return -1;
		}
		if (step < 2) continue;
		
		auto dest = c1[i];
		if (c2[i] != dest) continue;

		#ifdef _APOLLO_MEMCHECK
		if (!VirtualQuery(dest, &mbi, sizeof mbi)) continue;
		if ((mbi.Protect & pmask) == 0) continue;
		#endif

		if (memcmp(dest, gml_Script_, std::size(gml_Script_) - 1) != 0) continue;
		gmlOffsets.YYObjectBase.className = i * sizeof(void*);
		gmlClassOf.LuaState = (const char*)dest;
		trouble = false;
		return 1;
	}
	return -1;
}

dllgm void apollo_init_3(RValue* script_execute, RValue* defaultSelf, RValue* asset_get_index,
	RValue* luaRef, RValue* luaTable, RValue* luaFunction, RValue* luaUserdata
) {
	gml_Func.script_execute = script_execute->getCppFunc();
	gmlClassOf.LuaRef = luaRef->getObjectClass();
	gmlClassOf.LuaTable = luaTable->getObjectClass();
	gmlClassOf.LuaFunction = luaFunction->getObjectClass();
	gmlClassOf.LuaUserdata = luaUserdata->getObjectClass();
	GML::defaultSelf = YYStructGetMember(defaultSelf, "__self__");
	gml_Func.asset_get_index = asset_get_index->getCppFunc();
	gml_Script = {};
}

#if 0 // strictly for staring in the debugger.
class CInstanceBase {
public:
	RValue* yyvars;
	virtual ~CInstanceBase() {};
	virtual RValue& getYYVarRef(int index) = 0;
	virtual RValue& getYYVarRefL(int index) = 0;
};
class YYObjectBase : public CInstanceBase {
public:
	YYObjectBase* m_pNextObject;
	YYObjectBase* m_pPrevObject;
	YYObjectBase* m_prototype;
	const char* m_class;
};
#endif

static YYRunnerInterface g_YYRunnerInterface{};
YYRunnerInterface* g_pYYRunnerInterface;
__declspec(dllexport) void YYExtensionInitialise(const struct YYRunnerInterface* _struct, size_t _size) {
	if (_size < sizeof(YYRunnerInterface)) {
		memcpy(&g_YYRunnerInterface, _struct, _size);
	} else {
		memcpy(&g_YYRunnerInterface, _struct, sizeof(YYRunnerInterface));
	}
	g_pYYRunnerInterface = &g_YYRunnerInterface;
}

dllx double apollo_sleep(double ms) {
	if (g_pYYRunnerInterface) {
		Timing_Sleep((int64_t)ms);
	} else Sleep((int)ms);
	return 0;
}#include "stdafx.h"
#include "apollo_shared.h"
#define __RELFILE__ "apollo_interop.cpp"

namespace Apollo {
	void initLuaRef(lua_State* L);
	void initArrayRef(lua_State* L);
	void initStructRef(lua_State* L);
}
void apollo_interop_init(ApolloState* wrapState, lua_State* L) {
	luaL_newmetatable(L, "ApolloState");
	luaL_newmetatable(L, "RValuePtr");
	lua_pop(L, 2);

	// reg.apolloState = ApolloState(wrapState)
	lua_pushstring(L, "apolloState");
	auto ptr = lua_newuserdata_t<ApolloState*>(L);
	*ptr = wrapState;
	luaL_getmetatable(L, "ApolloState");
	lua_setmetatable(L, -2);
	lua_settable(L, LUA_REGISTRYINDEX);

	Apollo::initLuaRef(L);
	Apollo::initArrayRef(L);
	Apollo::initStructRef(L);
	if (lua_gettop(L) != 0) trace("unbalanced stack after interop_init: %s", Apollo::printLuaStack(L));
}#include "stdafx.h"
#include "apollo_shared.h"
#include "apollo_lua_ref.lua.h"
#define __RELFILE__ "apollo_lua_ref.cpp"
// A wrapper for a Lua reference-type (tables, functions, userdata) for use in GML.
// The GML half of this is LuaRef.

dllm void lua_ref_create_post(YYFuncArgs) {
	YYStructAddRValue(&arg[0], "@@Dispose@@", &arg[1]);
}
namespace Apollo {
	static int refConstructorsPerType[LUA_NUMTYPES] = { -1 };
	static void refConstructorsPerType_init() {
		for (int i = 0; i < std::size(refConstructorsPerType); i++) {
			refConstructorsPerType[i] = gml_Script.lua_ref_create_raw;
		}
		refConstructorsPerType[LUA_TTABLE] = gml_Script.lua_ref_create_raw_table;
		refConstructorsPerType[LUA_TFUNCTION] = gml_Script.lua_ref_create_raw_function;
		refConstructorsPerType[LUA_TUSERDATA] = gml_Script.lua_ref_create_raw_userdata;
	}
	static RValue* refResult;
	static int createLuaRefStruct(lua_State* L) {
		auto state = Apollo::getState(L);
		auto uid = lua_tointeger(L, 1);
		auto type = lua_type(L, 2);

		if (refConstructorsPerType[0] < 0) refConstructorsPerType_init();
		auto scriptID = refConstructorsPerType[type];

		RValue args[3], result;
		args[0].setScriptID(scriptID);
		args[1].setTo(state->selfValue);
		args[2].setInt64(uid);
		GML::script_execute_def_for(result, args, L);
		
		auto ptr = lua_newuserdata_t<RValue*>(L);
		*ptr = YYStructGetMember(&result, "__self__");
		luaL_getmetatable(L, "RValuePtr");
		lua_setmetatable(L, -2);

		result.free();
		args[1].free();
		return 1;
	}
	void initLuaRef(lua_State* L) {
		lua_pushcfunction(L, createLuaRefStruct);
		lua_setglobal(L, "__apollo_tmp");

		luaL_dostring_trace(L, "lua_ref", __lua_ref_init);
	}

	void createLuaRef(RValue* result, lua_State* L, int ind) {
		lua_getglobal(L, "__apollo_ref_to_rvalue");
		lua_pushvalue(L, ind > 0 ? ind : ind - 1);
		if (lua_pcall(L, 1, 1, 0)) {
			trace("Error creating ref! %s", lua_tostring(L, -1));
			result->kind = VALUE_UNDEFINED;
			result->ptr = nullptr;
			return;
		}
		auto ptr = (RValue**)luaL_testudata(L, -1, "RValuePtr");
		if (ptr) {
			COPY_RValue(result, *ptr);
		} else {
			result->kind = VALUE_UNDEFINED;
			result->ptr = nullptr;
		}
		lua_pop(L, 1);
	}
}
#include "stdafx.h"
#include "apollo_shared.h"

dllgm void lua_stack_discard(lua_State* L, int count) {
	lua_pop(L, count);
}
dllgm void lua_stack_clear(lua_State* L) {
	lua_settop(L, 0);
}

dllgm int lua_stack_size(lua_State* L) {
	return lua_gettop(L);
}
dllgm void lua_stack_resize(lua_State* L, int index) {
	lua_settop(L, index);
}

dllgm void lua_stack_get(YYResult& result, lua_State* L, int index) {
	Apollo::luaToGML(&result, L, index);
}

dllgm void lua_stack_pop(YYResult& result, lua_State* L) {
	Apollo::popLuaStackValue(&result, L);
}
dllgm void lua_stack_pop_multret(YYResult& result, lua_State* L, int count = -1) {
	Apollo::popLuaStackValuesAsArray(&result, L, count);
}

dllgm void lua_stack_push(lua_State* L, YYRest values) {
	for (int i = 0; i < values.length; i++) Apollo::pushGMLtoLuaStack(&values[i], L);
}
dllgm int lua_stack_push_ext(lua_State* L, YYArrayItems valArray, int offset = 0, int count = -1) {
	valArray.procCountOffset(&count, &offset);
	auto till = offset + count;
	for (int i = offset; i < till; i++) Apollo::pushGMLtoLuaStack(&valArray[i], L);
	return count;
}
dllgm void lua_stack_push_global(lua_State* L, const char* name) {
	lua_getglobal(L, name);
}

dllgm void lua_rawcall(YYResult& result, lua_State* L, int numArgs) {
	dllm_handle_lua_error(lua_pcall(L, numArgs, 1, 0));
	Apollo::popLuaStackValue(&result, L);
}
dllgm void lua_rawcall_multret(YYResult& result, lua_State* L, int numArgs) {
	dllm_handle_lua_error(lua_pcall(L, numArgs, LUA_MULTRET, 0));
	Apollo::popLuaStackValuesAsArray(&result, L);
}
dllgm int lua_rawcall_ext(lua_State* L, int numArgs, int numResults) {
	return lua_pcall(L, numArgs, numResults, 0) == LUA_OK;
}
dllgm void lua_handle_rawerror(lua_State* L) {
	Apollo::handleLuaError(L);
}#include "stdafx.h"
#include "apollo_shared.h"

lua_next_error_t lua_next_error{};
///
dllx void lua_show_error(const char* text) {
	lua_next_error.text = text;
	lua_next_error.hasValue = true;
}

namespace Apollo {
	const char* printLuaStack(lua_State* L, const char* label) {
		// what a mess
		static std::string str{};
		auto n = lua_gettop(L);
		str = std::string(label) + " [" + std::to_string(n) + "]:";
		for (int i = 1; i <= n; i++) {
			lua_pushvalue(L, i);
			auto ti = lua_type(L, -1);
			auto tn = lua_typename(L, ti);
			std::string s;
			if (ti == LUA_TBOOLEAN) {
				s = lua_toboolean(L, -1) ? "true" : "false";
			} else if (ti == LUA_TNUMBER) {
				s = std::to_string(lua_tonumber(L, -1));
			} else if (ti == LUA_TFUNCTION) {
				char tmp[9] = "";
				sprintf(tmp, "%p", lua_tocfunction(L, -1));
			} else {
				auto ps = lua_tostring(L, -1);
				s = ps ? ps : "???";
			}
			lua_pop(L, 1);

			str += "\n" + std::to_string(i)
				+ "\t" + (tn ? tn : "?")
				+ "\t" + s;
		}
		return str.c_str();
	}


	void handleLuaError(lua_State* L, ApolloState* state) {
		if (state == nullptr) state = Apollo::getState(L);
		auto error_text = lua_tostring(L, -1);
		luaL_traceback(L, L, error_text, 0);
		error_text = lua_tostring(L, -1);
		//trace("lua error: %s", error_text);

		static RValue args[3], result;
		args[0].setScriptID(gml_Script.lua_proc_error_raw);
		args[1].setTo(state->selfValue);
		YYCreateString(&args[2], error_text);
		lua_pop(L, 2);
		GML::script_execute_def(result, args);
	}
}#include "stdafx.h"
#include "apollo_shared.h"

namespace Apollo {
	struct GmlStructData {
		int64_t uid = 0;
		bool isCrossRef = false;
	};
	static inline GmlStructData getData(lua_State* L, int ind = 1) {
		auto ptr = (GmlStructData*)luaL_testudata(L, ind, "GmlStruct");
		if (ptr == nullptr) return {};
		return *ptr;
	}
	template<size_t argc> static void setupCall(RValue(&args)[argc], int64_t uid, lua_State* L, int script_id, ApolloState* state = nullptr) {
		if (state == nullptr) state = Apollo::getState(L);
		static_assert(argc >= 3, "Not enough arguments!");
		args[0].setScriptID(script_id);
		args[1].setTo(state->selfValue);
		args[2].setInt64(uid);
	}
	static int createGmlStructUD(lua_State* L) {
		auto uid = lua_tointeger(L, 1);
		auto isCrossRef = lua_toboolean(L, 2);
		auto ptr = lua_newuserdata_t<GmlStructData>(L);
		ptr->uid = uid;
		ptr->isCrossRef = isCrossRef;
		luaL_getmetatable(L, "GmlStruct");
		lua_setmetatable(L, -2);
		return 1;
	}
	static int __gc(lua_State* L) {
		auto inf = getData(L);
		static RValue args[3], result;
		setupCall(args, inf.uid, L, gml_Script.lua_gml_ref_free);
		GML::script_execute_def(result, args);
		args[1].free();
		return 0;
	}
	static int __index(lua_State* L) {
		auto inf = getData(L);
		static RValue args[4], result;
		auto script = inf.isCrossRef ? gml_Script.lua_gml_cross_ref_get_key : gml_Script.lua_gml_ref_get_key;
		setupCall(args, inf.uid, L, script);
		Apollo::luaToGML(&args[3], L, 2);
		GML::script_execute_def_for(result, args, L);
		args[1].free();
		args[3].free();
		Apollo::pushGMLtoLuaStack(&result, L);
		return 1;
	}
	static int __newindex(lua_State* L) {
		auto inf = getData(L);
		static RValue args[5], result;
		auto script = inf.isCrossRef ? gml_Script.lua_gml_cross_ref_set_key : gml_Script.lua_gml_ref_set_key;
		setupCall(args, inf.uid, L, script);
		Apollo::luaToGML(&args[3], L, 2);
		Apollo::luaToGML(&args[4], L, 3);
		GML::script_execute_def_for(result, args, L);
		args[1].free();
		args[3].free();
		args[4].free();
		return 0;
	}
	static int __call(lua_State* L) {
		auto inf = getData(L);
		static RValue args[5], result;
		auto state = Apollo::getState(L);
		auto script = inf.isCrossRef ? gml_Script.lua_gml_cross_ref_invoke : gml_Script.lua_gml_ref_invoke;
		setupCall(args, inf.uid, L, script, state);

		// make sure that argument array is big enough:
		auto argc = lua_gettop(L) - 1;
		auto argArr = state->callArgs;
		if (argArr->getArrayLength() < argc) {
			SET_RValue(argArr, &args[0], (YYObjectBase*)state->selfValue->ptr, argc - 1);
		}

		auto argItems = argArr->getArrayItems();
		for (int i = 0; i < argc; i++) {
			Apollo::luaToGML(&argItems[i], L, 2 + i);
		}
		args[3].setTo(argArr);
		args[4].setReal(argc);

		GML::script_execute_def_for(result, args, L);

		argItems = argArr->getArrayItems();
		for (int i = 0; i < argc; i++) {
			argItems[i].free();
		}
		args[1].free();
		args[3].free();

		Apollo::pushGMLtoLuaStack(&result, L);
		return 1;
	}
	static luaL_Reg metaPairs[] = {
		{ "__gc", __gc },
		{ "__index", __index },
		{ "__newindex", __newindex },
		{ "__call", __call },
		{ 0, 0 }
	};
	void initStructRef(lua_State* L) {
		luaL_newmetatable(L, "GmlStruct");
		luaL_setfuncs(L, metaPairs, 0);
		lua_pop(L, 1);

		lua_pushcfunction(L, createGmlStructUD);
		lua_setglobal(L, "__apollo_tmp");

		luaL_dostring_trace(L, "lua_struct_ref", R"lua(
(function()
	local _create_udata = __apollo_tmp
	__apollo_tmp = nil
	
	local _uid_to_udata = setmetatable({}, { __mode = "v" })
	__apollo_get_gml_struct_udata = function(uid, isCrossRef)
		local ud = _uid_to_udata[uid]
		if (ud == nil) then
			ud = _create_udata(uid, isCrossRef)
			_uid_to_udata[uid] = ud
		end
		return ud
	end
end)()
)lua")
	}
}#include "gml_ext.h"
#include "gml_extm.h"
#include "apollo_state.h"
#include "apollo_shared.h"
extern void apollo_init_array(RValue* a2, RValue* a3, RValue* a4);
/// apollo_init_array(a2, a3, a4)
dllm void apollo_init_array_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "apollo_init_array"
	__YYArgCheck(3);
	RValue* _arg_a2; __YYArg_RValue_ptr("a2", _arg_a2, 0);
	RValue* _arg_a3; __YYArg_RValue_ptr("a3", _arg_a3, 1);
	RValue* _arg_a4; __YYArg_RValue_ptr("a4", _arg_a4, 2);
	apollo_init_array(_arg_a2, _arg_a3, _arg_a4);
	#undef __YYFUNCNAME__
}

extern void apollo_init_3(RValue* script_execute, RValue* defaultSelf, RValue* asset_get_index, RValue* luaRef, RValue* luaTable, RValue* luaFunction, RValue* luaUserdata);
/// apollo_init_3(script_execute, defaultSelf, asset_get_index, luaRef, luaTable, luaFunction, luaUserdata)
dllm void apollo_init_3_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "apollo_init_3"
	__YYArgCheck(7);
	RValue* _arg_script_execute; __YYArg_RValue_ptr("script_execute", _arg_script_execute, 0);
	RValue* _arg_defaultSelf; __YYArg_RValue_ptr("defaultSelf", _arg_defaultSelf, 1);
	RValue* _arg_asset_get_index; __YYArg_RValue_ptr("asset_get_index", _arg_asset_get_index, 2);
	RValue* _arg_luaRef; __YYArg_RValue_ptr("luaRef", _arg_luaRef, 3);
	RValue* _arg_luaTable; __YYArg_RValue_ptr("luaTable", _arg_luaTable, 4);
	RValue* _arg_luaFunction; __YYArg_RValue_ptr("luaFunction", _arg_luaFunction, 5);
	RValue* _arg_luaUserdata; __YYArg_RValue_ptr("luaUserdata", _arg_luaUserdata, 6);
	apollo_init_3(_arg_script_execute, _arg_defaultSelf, _arg_asset_get_index, _arg_luaRef, _arg_luaTable, _arg_luaFunction, _arg_luaUserdata);
	#undef __YYFUNCNAME__
}

extern void lua_global_get(YYResult& result, lua_State* L, const char* name);
/// lua_global_get(L, name)->
dllm void lua_global_get_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_get"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_name; __YYArg_const_char_ptr("name", _arg_name, 1);
	lua_global_get(result, _arg_L, _arg_name);
	#undef __YYFUNCNAME__
}

extern void lua_global_set(lua_State* L, const char* name, RValue* value);
/// lua_global_set(L, name, value)
dllm void lua_global_set_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_set"
	__YYArgCheck(3);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_name; __YYArg_const_char_ptr("name", _arg_name, 1);
	RValue* _arg_value; __YYArg_RValue_ptr("value", _arg_value, 2);
	lua_global_set(_arg_L, _arg_name, _arg_value);
	#undef __YYFUNCNAME__
}

extern void lua_global_call(YYResult& result, lua_State* L, const char* fname, YYRest args);
/// lua_global_call(L, fname, ...args)->
dllm void lua_global_call_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_call"
	__YYArgCheck_rest(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_fname; __YYArg_const_char_ptr("fname", _arg_fname, 1);
	YYRest _arg_args; __YYArg_YYRest("args", _arg_args, 2);
	lua_global_call(result, _arg_L, _arg_fname, _arg_args);
	#undef __YYFUNCNAME__
}

extern void lua_global_call_ext(YYResult& result, lua_State* L, const char* fname, YYArrayItems argArray, int offset, int numArgs);
/// lua_global_call_ext(L, fname, argArray, ?offset, ?numArgs)->
dllm void lua_global_call_ext_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_call_ext"
	__YYArgCheck_range(3, 5);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_fname; __YYArg_const_char_ptr("fname", _arg_fname, 1);
	YYArrayItems _arg_argArray; __YYArg_YYArrayItems("argArray", _arg_argArray, 2);
	int _arg_offset;
	if (argc > 3) {
		__YYArg_int("offset", _arg_offset, 3);
	} else _arg_offset = 0;
	int _arg_numArgs;
	if (argc > 4) {
		__YYArg_int("numArgs", _arg_numArgs, 4);
	} else _arg_numArgs = -1
;
	lua_global_call_ext(result, _arg_L, _arg_fname, _arg_argArray, _arg_offset, _arg_numArgs);
	#undef __YYFUNCNAME__
}

extern void lua_global_call_multret(YYResult& result, lua_State* L, const char* fname, YYRest args);
/// lua_global_call_multret(L, fname, ...args)->
dllm void lua_global_call_multret_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_call_multret"
	__YYArgCheck_rest(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_fname; __YYArg_const_char_ptr("fname", _arg_fname, 1);
	YYRest _arg_args; __YYArg_YYRest("args", _arg_args, 2);
	lua_global_call_multret(result, _arg_L, _arg_fname, _arg_args);
	#undef __YYFUNCNAME__
}

extern void lua_global_call_ext_multret(YYResult& result, lua_State* L, const char* fname, YYArrayItems argArray, int offset, int numArgs);
/// lua_global_call_ext_multret(L, fname, argArray, ?offset, ?numArgs)->
dllm void lua_global_call_ext_multret_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_global_call_ext_multret"
	__YYArgCheck_range(3, 5);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_fname; __YYArg_const_char_ptr("fname", _arg_fname, 1);
	YYArrayItems _arg_argArray; __YYArg_YYArrayItems("argArray", _arg_argArray, 2);
	int _arg_offset;
	if (argc > 3) {
		__YYArg_int("offset", _arg_offset, 3);
	} else _arg_offset = 0;
	int _arg_numArgs;
	if (argc > 4) {
		__YYArg_int("numArgs", _arg_numArgs, 4);
	} else _arg_numArgs = -1
;
	lua_global_call_ext_multret(result, _arg_L, _arg_fname, _arg_argArray, _arg_offset, _arg_numArgs);
	#undef __YYFUNCNAME__
}

extern void lua_stack_discard(lua_State* L, int count);
/// lua_stack_discard(L, count)
dllm void lua_stack_discard_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_discard"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_count; __YYArg_int("count", _arg_count, 1);
	lua_stack_discard(_arg_L, _arg_count);
	#undef __YYFUNCNAME__
}

extern void lua_stack_clear(lua_State* L);
/// lua_stack_clear(L)
dllm void lua_stack_clear_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_clear"
	__YYArgCheck(1);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	lua_stack_clear(_arg_L);
	#undef __YYFUNCNAME__
}

extern int lua_stack_size(lua_State* L);
/// lua_stack_size(L)->
dllm void lua_stack_size_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_size"
	__YYArgCheck(1);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _result = lua_stack_size(_arg_L);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern void lua_stack_resize(lua_State* L, int index);
/// lua_stack_resize(L, index)
dllm void lua_stack_resize_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_resize"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_index; __YYArg_int("index", _arg_index, 1);
	lua_stack_resize(_arg_L, _arg_index);
	#undef __YYFUNCNAME__
}

extern void lua_stack_get(YYResult& result, lua_State* L, int index);
/// lua_stack_get(L, index)->
dllm void lua_stack_get_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_get"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_index; __YYArg_int("index", _arg_index, 1);
	lua_stack_get(result, _arg_L, _arg_index);
	#undef __YYFUNCNAME__
}

extern void lua_stack_pop(YYResult& result, lua_State* L);
/// lua_stack_pop(L)->
dllm void lua_stack_pop_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_pop"
	__YYArgCheck(1);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	lua_stack_pop(result, _arg_L);
	#undef __YYFUNCNAME__
}

extern void lua_stack_pop_multret(YYResult& result, lua_State* L, int count);
/// lua_stack_pop_multret(L, ?count)->
dllm void lua_stack_pop_multret_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_pop_multret"
	__YYArgCheck_range(1, 2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_count;
	if (argc > 1) {
		__YYArg_int("count", _arg_count, 1);
	} else _arg_count = -1;
	lua_stack_pop_multret(result, _arg_L, _arg_count);
	#undef __YYFUNCNAME__
}

extern void lua_stack_push(lua_State* L, YYRest values);
/// lua_stack_push(L, ...values)
dllm void lua_stack_push_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_push"
	__YYArgCheck_rest(1);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	YYRest _arg_values; __YYArg_YYRest("values", _arg_values, 1);
	lua_stack_push(_arg_L, _arg_values);
	#undef __YYFUNCNAME__
}

extern int lua_stack_push_ext(lua_State* L, YYArrayItems valArray, int offset, int count);
/// lua_stack_push_ext(L, valArray, ?offset, ?count)->
dllm void lua_stack_push_ext_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_push_ext"
	__YYArgCheck_range(2, 4);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	YYArrayItems _arg_valArray; __YYArg_YYArrayItems("valArray", _arg_valArray, 1);
	int _arg_offset;
	if (argc > 2) {
		__YYArg_int("offset", _arg_offset, 2);
	} else _arg_offset = 0;
	int _arg_count;
	if (argc > 3) {
		__YYArg_int("count", _arg_count, 3);
	} else _arg_count = -1;
	int _result = lua_stack_push_ext(_arg_L, _arg_valArray, _arg_offset, _arg_count);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern void lua_stack_push_global(lua_State* L, const char* name);
/// lua_stack_push_global(L, name)
dllm void lua_stack_push_global_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_stack_push_global"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_name; __YYArg_const_char_ptr("name", _arg_name, 1);
	lua_stack_push_global(_arg_L, _arg_name);
	#undef __YYFUNCNAME__
}

extern void lua_rawcall(YYResult& result, lua_State* L, int numArgs);
/// lua_rawcall(L, numArgs)->
dllm void lua_rawcall_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_rawcall"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_numArgs; __YYArg_int("numArgs", _arg_numArgs, 1);
	lua_rawcall(result, _arg_L, _arg_numArgs);
	#undef __YYFUNCNAME__
}

extern void lua_rawcall_multret(YYResult& result, lua_State* L, int numArgs);
/// lua_rawcall_multret(L, numArgs)->
dllm void lua_rawcall_multret_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_rawcall_multret"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_numArgs; __YYArg_int("numArgs", _arg_numArgs, 1);
	lua_rawcall_multret(result, _arg_L, _arg_numArgs);
	#undef __YYFUNCNAME__
}

extern int lua_rawcall_ext(lua_State* L, int numArgs, int numResults);
/// lua_rawcall_ext(L, numArgs, numResults)->
dllm void lua_rawcall_ext_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_rawcall_ext"
	__YYArgCheck(3);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	int _arg_numArgs; __YYArg_int("numArgs", _arg_numArgs, 1);
	int _arg_numResults; __YYArg_int("numResults", _arg_numResults, 2);
	int _result = lua_rawcall_ext(_arg_L, _arg_numArgs, _arg_numResults);
	__YYResult_int(_result);
	#undef __YYFUNCNAME__
}

extern void lua_handle_rawerror(lua_State* L);
/// lua_handle_rawerror(L)
dllm void lua_handle_rawerror_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_handle_rawerror"
	__YYArgCheck(1);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	lua_handle_rawerror(_arg_L);
	#undef __YYFUNCNAME__
}

extern void* lua_state_create_raw(RValue* gmlState, RValue* destructor);
/// lua_state_create_raw(gmlState, destructor)->
dllm void lua_state_create_raw_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_state_create_raw"
	__YYArgCheck(2);
	RValue* _arg_gmlState; __YYArg_RValue_ptr("gmlState", _arg_gmlState, 0);
	RValue* _arg_destructor; __YYArg_RValue_ptr("destructor", _arg_destructor, 1);
	void* _result = lua_state_create_raw(_arg_gmlState, _arg_destructor);
	__YYResult_void_ptr(_result);
	#undef __YYFUNCNAME__
}

extern void lua_add_code(YYResult& result, lua_State* L, const char* code);
/// lua_add_code(L, code)->
dllm void lua_add_code_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_add_code"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_code; __YYArg_const_char_ptr("code", _arg_code, 1);
	lua_add_code(result, _arg_L, _arg_code);
	#undef __YYFUNCNAME__
}

extern void lua_add_code_multret(YYResult& result, lua_State* L, const char* code);
/// lua_add_code_multret(L, code)->
dllm void lua_add_code_multret_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "lua_add_code_multret"
	__YYArgCheck(2);
	lua_State* _arg_L; __YYArg_lua_State_ptr("L", _arg_L, 0);
	const char* _arg_code; __YYArg_const_char_ptr("code", _arg_code, 1);
	lua_add_code_multret(result, _arg_L, _arg_code);
	#undef __YYFUNCNAME__
}

extern bool is_lua_ref(RValue* val);
/// is_lua_ref(val)->
dllm void is_lua_ref_yyr(RValue& result, CInstance* self, CInstance* other, int argc, RValue* arg) {
	#define __YYFUNCNAME__ "is_lua_ref"
	__YYArgCheck(1);
	RValue* _arg_val; __YYArg_RValue_ptr("val", _arg_val, 0);
	bool _result = is_lua_ref(_arg_val);
	__YYResult_bool(_result);
	#undef __YYFUNCNAME__
}

// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

#include "stdafx.h"
#include "gml_api.h"
#define __RELFILE__ "gml_api.cpp"

GmlOffsets gmlOffsets{};
GmlClassOf gmlClassOf{};
gml_Func_t gml_Func;
gml_Script_t gml_Script;
int gml_Script_t::init(const char* name) {
	if (gml_Func.asset_get_index) {
		auto id = GML::asset_get_index(name);
		if (id < 0) trace("Required script %s is missing.", name);
		return id;
	} else return -1;
}

namespace GML {
	RValue* defaultSelf;
}

void YYCreateEmptyArray(RValue* result, int size) {
	static std::vector<double> dummies{};
	if (dummies.size() < size) dummies.resize(size, 0);
	YYCreateArray(result, size, dummies.data());
}

// Could be inline but figuring out how to cross-reference two types is icky
bool RValue::tryGetLuaState(lua_State** out) {
	switch (kind & MASK_KIND_RVALUE) {
		case VALUE_OBJECT: {
			if (getObjectClass() != gmlClassOf.LuaState) return false;
			// it would be faster to find a variable slot but that's a lot of work!
			auto rv = YYStructGetMember(this, "__ptr__");
			if (rv->kind != VALUE_PTR) return false;
			*out = ((ApolloState*)rv->ptr)->luaState;
			return true;
		};
		case VALUE_PTR:
			*out = ((ApolloState*)ptr)->luaState;
			return true;
		default:
			return false;
	}
}// stdafx.cpp : source file that includes just the standard includes
// Apollo.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file
