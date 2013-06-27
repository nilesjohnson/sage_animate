A framework for animations with Sage

AUTHORS
-------

* Niles Johnson (2013)  <http://www.nilesjohnson.net>


LICENSE: GPLv3
-------

This file is part of a program for creating animations with the Sage 
mathematics system <http://sagemath.org>.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


OVERVIEW
---------

An outline of this framework.

The classes defined in sage_animate are a framework for 3D animation.
They aim to support an animator throughout the development process.
There are surely many ways to do this, and the strategy we've chosen
may or may not be most natural.  The overriding principle is to build
flexibility into the framework by making it more modular.

We assume that the animator begins by "storyboarding" -- writing the
code which will produce key still frames for the animation.  This
should probably be done with the Scene or Frame classes, developing
functionality to produce a range of images for the animation.

The next stage, we assume, is "rough cutting" -- designing several 
animation sequences which will be appended to make the full
animation.  Each of these sequences could be a separate Segment
object: a parametrized sequence of Frames determined by a function on
some interval.

Next the sequences can be assembled into a Timeline object.  This is
where the animator can control render parameters such as frame rate,
resolution, and file names.  Timing details are provided to aid in
synchronizing with prerecorded audio.  Test rendering can be done with
the render_segment functions, optionally using the "step_size" keyword
to render every kth frame for some k > 1.

After the frames are rendered, use a tool such as ffmpeg to combine
them into an animation.  Currently the Timeline class doesn't provide
an interface to ffmpeg, so you have to run those commands separately.
An example command is given below.


USAGE
------

An outline / suggested workflow.  See demo.sage for a demonstration of
this workflow.

* Begin by designing Frame and Scene classes which draw still scenes
  for (a segment of) your animation.  They should be able to produce a
  variety of still images with different camera angles, different
  objects, different text annotations, etcetera, as appropriate for
  your animation.  At minimum, the Scene object should be able to
  produce storyboard stills for this segment of the animation.

  The Scene class is for defining:

  -  Functions which produce objects for the Scene
  -  Functions which determine where to place objects, camera, light
     sources, etc.

  The Frame class is for:

  -  Setting Scene class and its inputs
  -  Rendering test images during development

  One goal should be that Frame objects are small and fast, deferring
  time- and memory-intensive calculations to Scene objects.  The
  Sequence and Timeline classes mainly work with Frame objects to keep
  development functions fast.


* Next, design functions which will generate a sequence of frames as a
  function of time.  Use these to build animation Segments, and join
  the Segments into a Timeline object.

  The Sequence class is for defining:

  -  Functions to produce Frames (and Scenes)

  The Timeline class is for:

  -  Setting graphical attributes of the whole animation (resolution, frame
  rate, file naming conventions, etc.)
  -  Setting segment options (if necessary)
  -  Rendering many Frames

* Finally, combine the rendered images into an animation with
  something like ffmpeg.  ffmpeg is a complex and full-featured tool,
  with somewhat sparse documentation.  Here is one example using it to
  generate an animation from a sequence of png images and an mp3 audio
  file:

ffmpeg -y -r 30 -vcodec png -i /path/to/animation-frame%08d.png -i /path/to/audio.mp3 -t 00:02:54.3 -map 0:0 -map 1:0 -vcodec libx264 -crf 20 -threads 0 -tune animation animation-out.mp4

  For details on ffmpeg, you could start with these two:

  -  http://ffmpeg.org/ffmpeg.html

  -  http://ffmpeg.org/trac/ffmpeg/wiki/x264EncodingGuide



MORE INFORMATION
------------------

Details of some design decisions.

*Segments and Timelines*

When an animation grows to thousands of frames, development can become
cumbersome and slow.  The Segment class aims to alleviate this by
allowing the animator to work with smaller pieces during development.

However this leads to a difficulty with settings that should be
uniform for the entire animation (e.g. resolution or file format).
The Timeline class is intended to manage these at an animation-wide
level, but it needs to pass them to individual frames for rendering.
We wanted to do this without storing frames, so we designed Frame
objects to check whether they are part of an ambient Timeline object
or not.  This is controlled by the _timeline attribute of a Segment
object.  It is set to None by default, and set to the containing
Timeline object when a segment is appended to a timeline.  When frames
are generated by a segment object, it checks the value of this
_timeline attribute to see if there are animation-wide settings to
apply.


*Scenes and Frames*

A natural starting point for 3D images is to write a function which
produces an image according to various input parameters (position,
color, opacity, etc.).  As the range of desired outputs becomes more
complex, the input parameters grow more complex.  A next step in
organization might be to take inputs from a dictionary, with the
dictionary produced by a helper function.  The Scene/Frame paradigm
follows essentially the same structure, where a Scene is a generalized function
for producing images, and a Frame is a generalized container for input
parameters.  

