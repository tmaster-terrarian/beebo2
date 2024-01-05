if(instance_exists(target))
with instance_create_depth(x, y, target.depth - 4, fx_cut)
{
    image_index = 1
    x = (other.target.bbox_left + other.target.bbox_right) / 2
    y = (other.target.bbox_top + other.target.bbox_bottom) / 2
}
