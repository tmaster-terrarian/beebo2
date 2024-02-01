meshes = []
with(par_solid)
{
    array_push(other.meshes, {
        verts: [
            {x: self.bbox_left, y: self.bbox_bottom},
            {x: self.bbox_right, y: self.bbox_bottom},
            {x: self.bbox_right, y: self.bbox_top},
            {x: self.bbox_left, y: self.bbox_top},
            {x: self.bbox_left, y: self.bbox_bottom}
        ]
    })
}
