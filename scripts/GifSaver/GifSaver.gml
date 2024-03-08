function GifSaver(scale = 1) constructor
{
    self.gifImg = -1
    self.surf = -1
    self.scale = scale

    self.startRecording = function()
    {
        self.gifImg = gif_open(SC_W * self.scale, SC_H * self.scale)
        if(!surface_exists(self.surf))
            self.surf = surface_create(SC_W * self.scale, SC_H * self.scale)
    }

    self.step = function(surf)
    {
        if(surface_exists(surf))
        {
            if(!surface_exists(self.surf))
                self.surf = surface_create(SC_W * self.scale, SC_H * self.scale)

            surface_set_target(self.surf)
            draw_surface_ext(surf, 0, 0, self.scale, self.scale, 0, c_white, 1)
            surface_reset_target()

            gif_add_surface(self.gifImg, self.surf, 5);
        }
    }

    self.stopRecording = function()
    {
        var t = date_current_datetime()
        gif_save(self.gifImg, $"captures/{date_get_year(t)}-{date_get_month(t)}-{date_get_day(t)} {date_get_hour(t)}-{date_get_minute(t)}-{date_get_second(t)}.gif");
        surface_exists(self.surf)
            surface_free(self.surf)
    }
}
