event_inherited();

ponytail_visible = 1
if(running && sprite_index != _sp.crawl)
{
    ponytail_visible = 1
}
else if(sprite_index == _sp.crawl)
{
    ponytail_visible = 0
}
else if(sprite_index == _sp.idle || sprite_index == _sp.idle_lookup)
{
    ponytail_visible = 0
}
else if(state == "wallslide")
{
    ponytail_visible = 1
}
else if(state == "ledgegrab")
{
    ponytail_visible = 1
}
else if(state == "ledgeclimb")
{
    ponytail_visible = (timer0 <= 5)
}
else if(duck)
{
    ponytail_visible = 0
}
else
{
    ponytail_visible = 1
}
