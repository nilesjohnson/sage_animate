Base classes for animations with Sage

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


USAGE
------

An outline / suggested workflow:

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

  The Frame class is for setting:

  -  Graphic attributes (image format, resolution, filename, etc.)
  -  Scene options (if necessary)

  One goal should be that Frame objects are small and fast, deferring
  time- and memory-intensive calculations to Scene objects.  The
  Sequence and Timeline classes mainly work with Frame objects to keep
  development functions fast.


* Next, design functions which will generate a sequence of frames as a
  function of time.  Use these to build animation Segments, and join
  the Segments into a Timeline object.

  The Sequence class is for defining:

  -  Functions to produce Frames (and Scenes)

  The Timeline class is for setting:

  -  Graphical attributes of the whole animation (resolution, frame
  rate, file naming conventions, etc.)
  -  Segment options (if necessary)






