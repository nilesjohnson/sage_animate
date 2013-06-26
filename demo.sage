"""
Demonstration of the Timeline/Segment and Frame/Scene classes

AUTHORS: Niles Johnson (2013) <http://www.nilesjohnson.net>

#*****************************************************************************
#                  Copyright (C) 2013 by AUTHORS
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 3 of
#  the License, or (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************




EXAMPLES:

Defining a new Segment: `S(n)` returns a new frame object, represented by its file name::

    sage: load('demo.sage')
    sage: S = Segment('first',fade_in_bg,30)
    sage: S(0)

    sage: S(0).show() # view the rendered image by showing the scene
    sage: S(29).show()

Making a Timeline with multiple segments::

    sage: T = Timeline()
    sage: T.add_segment('fade in',fade_in_bg,.5)
    sage: T.add_segment('rotate',rotate_camera,1.5)

    sage: T.show_segments()
    (0) fade in: 0 -- 14
      0:00:00.000 -- 0:00:00.466
    (1) rotate: 15 -- 59
      0:00:00.500 -- 0:00:01.966

A Timeline can also be formed by adding two Segments, or adding a Segment to a Timeline::

    sage: S = Segment('first',fade_in_bg,30); S
    Animation segment: first;  30 frames. [0 -- 29]
    sage: P = Segment('first slow',fade_in_bg,60); P
    Animation segment: first slow;  60 frames. [0 -- 59]
    sage: Q = Segment('second',rotate_camera,30); Q
    Animation segment: second;  30 frames. [0 -- 29]
    
    sage: T = S + P; T
    An animation timeline with 2 segments.  Duration 0:00:03 sec.
    sage: T.show_segments()
    sage: T.show_segments()
    (0) first: 0 -- 29
      0:00:00.000 -- 0:00:00.966
    (1) first slow: 30 -- 89
      0:00:01.000 -- 0:00:02.966
    sage: T += Q
    sage: T.show_segments()
    (0) first: 0 -- 29
      0:00:00.000 -- 0:00:00.966
    (1) first slow: 30 -- 89
      0:00:01.000 -- 0:00:02.966
    (2) second: 90 -- 119
      0:00:03.000 -- 0:00:03.966


Render a timeline segment with `render_segment`; use `set_verbose(1)` to show verbose output, and `set_verbose(0)` to suppress::

    sage: set_verbose(1)
    sage: T.render_segment(0)

You can render every kth frame with an optional argument `step_size=k`.  Frames are rendered in parallel, with the number of processes detected automatically by Sage's `parallel` decorator.

The rendering parameters are set by the Timeline object.  These settings are stored in the `general_frame_settings` dictionary::

    sage: T.general_frame_settings
    {'frame_name': 'animation-frame',
    'image_format': '.png',
    ...
    'resolution': (544, 306)}

When values in this dictionary are updated, Frames will be rendered with the new settings.  The values can be updated directly, or with the helper functions such as `frame_name` or `resolution`::

    sage: T.resolution((640,480))
    (640, 480)
    sage: T.frame(0).resolution()
    (640, 480)

Use `render_all` to render all frames in an animation Timeline.  This simply calls `render_segment` on each Segment in the Timeline.

"""
load("timeline.sage")
load("frame.sage")

class DemoScene(Tachyon):
    """
    Demonstrating a Scene class.  Example based on twisted cubic
    example in sage.plot.plot3d.tachyon.Tachyon.

    EXAMPLES::

        sage: g = DemoScene()
        sage: g.show()
        sage: g.add_planes()
        sage: g.draw_cubic()
        sage: g.show()

    """
    def __init__(self,resolution=(512,512), camera_center=(3,0.3,0), look_at=(0,0,0), raydepth=8):
        xres = resolution[0]
        yres = resolution[1]
        Tachyon.__init__(self,
                         xres=xres,
                         yres=yres,
                         camera_center=camera_center,
                         look_at=look_at,
                         raydepth=8)

        self.light((4,3,2), 0.2, (1,1,1))

    def add_planes(self,color=(1,1,1)):
        """
        add background planes
        """
        self.texture('plane_texture', color=color)
        self.plane((0,0,-1), (0,0,1), 'plane_texture')
        self.plane((0,-20,0), (0,1,0), 'plane_texture')
        self.plane((-20,0,0), (1,0,0), 'plane_texture')
        
    def draw_cubic(self, opacities=(1,1,1), sphere_radii=.1):
        """
        draw spheres along twisted cubic
        """
        self.texture('t0', ambient=0.1, diffuse=0.9, specular=0.5, opacity=opacities[0], color=(1.0,0,0))
        self.texture('t1', ambient=0.1, diffuse=0.9, specular=0.3, opacity=opacities[1], color=(0,1.0,0))
        self.texture('t2', ambient=0.2,diffuse=0.7, specular=0.5, opacity=opacities[2], color=(0,0,1.0))
        self.cylinder((0,0,0), (0,0,1), 0.05,'t1')
        k=0
        for i in srange(-1,1,0.05):
            k += 1
            self.sphere((i,i^2 - 0.5,i^3), sphere_radii, 't%s'%(k%3))


class DemoFrame(Frame):
    """
    Demonstrating subclass of Frame class
    
    EXAMPLES::

        sage: F = DemoFrame(camera_center=(3,.5,.3))
        sage: g = F.scene()
        sage: g.show()
        
    """
    def __init__(self,
                 camera_center=(3,0.5,0.3),
                 plane_color=(1,1,1),
                 opacities=(1,1,.7),
                 sphere_radii=.1):
        Frame.__init__(self) # initialize frame with defaults
        self.scene_class(DemoScene) # reset Scene class
        self.camera_center = camera_center
        self.plane_color = plane_color
        self.opacities = opacities
        self.sphere_radii = sphere_radii

    def scene(self):
        """
        Redefine `scene` method for this class of Frames.
        """
        scene_class = self.scene_class() #DemoScene
        S = scene_class(resolution=self.resolution(), camera_center=self.camera_center) # instantiate scene class
        S.add_planes(self.plane_color)
        S.draw_cubic(self.opacities, self.sphere_radii)
        return S
        

"""
Some demo frame functions
"""
def fade_in_bg(t):
    """
    Redefine frame function on [0,1] fading background planes
    from black to white
    """
    custom_color = (t,t,t)
    F = DemoFrame(plane_color=custom_color)
    return F

def rotate_camera(t):
    """
    Camera positions in elliptical arc from (3,.5,.3) to (-3,.5,.3)
    """
    custom_center = vector((0,.5,.3)) + vector((3*cos(pi*t),2*sin(pi*t),0))
    F = DemoFrame(camera_center=custom_center)
    return F


