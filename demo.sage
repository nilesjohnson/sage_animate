"""
Demonstration of the Timeline/Segment and Frame/Scene classes

AUTHOR: Niles Johnson (2013)

#*****************************************************************************
#        Copyright (C) 2013 Niles Johnson <http://www.nilesjohnson.net>
#
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 3 of
#  the License, or (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************




EXAMPLES:

Defining a new Segment::

    sage: S = Segment('first',fade_in_bg,30)
    sage: S(0) # S(n) returns a frame object
    <class '__main__.DemoFrame'>

    sage: S(0).scene().show() # view the rendered image by showing the scene
    sage: S(29).scene().show()

Making a Timeline with multiple segments::

    sage: T = Timeline()
    sage: T.add_segment('fade in',fade_in_bg,.5)
    sage: T.add_segment('rotate',rotate_camera,1.5)

    sage: T.show_segments()
    (0) fade in: 0 -- 14.0000000000000
    0:00:00.000 -- 0:00:00.466
    (1) rotate: 15.0000000000000 -- 59.0000000000000
    0:00:00.500 -- 0:00:01.966

Render a segment::
    sage: T.render_segment(0) 

"""
load("timeline.sage")
load("frame.sage")

class DemoScene(Tachyon):
    """
    Demonstrating a Scene class.  Example based on twisted cubic
    example in sage.plot.plot3d.tachyon.Tachyon
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

        sage: f = DemoFrame(camera_center=(3,.5,.3))
        sage: s = f.scene()
        sage: s.show()
        
    """
    def __init__(self,
                 camera_center=(3,0.3,0),
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

