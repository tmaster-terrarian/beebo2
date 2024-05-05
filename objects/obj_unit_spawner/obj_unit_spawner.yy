{
  "$GMObject":"",
  "%Name":"obj_unit_spawner",
  "eventList":[
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":2,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":1,"eventType":3,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
  ],
  "managed":true,
  "name":"obj_unit_spawner",
  "overriddenProperties":[],
  "parent":{
    "name":"level",
    "path":"folders/Objects/level.yy",
  },
  "parentObjectId":null,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":1,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[
    {"$GMObjectProperty":"v1","%Name":"delay","filters":[],"listItems":[],"multiselect":false,"name":"delay","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"1","varType":0,},
    {"$GMObjectProperty":"v1","%Name":"index","filters":[
        "GMObject",
      ],"listItems":[],"multiselect":false,"name":"index","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"level","filters":[],"listItems":[],"multiselect":false,"name":"level","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"global.wave","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"items","filters":[],"listItems":[],"multiselect":false,"name":"items","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"[]","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"buffs","filters":[],"listItems":[],"multiselect":false,"name":"buffs","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"[]","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"team","filters":[],"listItems":[
        "Team.enemy",
        "Team.neutral",
        "Team.player",
      ],"multiselect":false,"name":"team","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"Team.enemy","varType":6,},
    {"$GMObjectProperty":"v1","%Name":"boss","filters":[],"listItems":[],"multiselect":false,"name":"boss","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"animate_spawn","filters":[],"listItems":[],"multiselect":false,"name":"animate_spawn","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":3,},
  ],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":null,
  "spriteMaskId":null,
  "visible":false,
}