"""
Animation Frame is a Sage object which produces an image from a Scene object.

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

"""
load("scene.sage")

class Frame(SageObject):
    """
    Container for data to produce Scene object
    """
    def __init__(self):        
        self._scene_class = Scene
        self._resolution = (544,306)
        self._file_name =  sage.misc.misc.tmp_filename(ext='.png')
            
    def scene_class(self,val=None):
        """
        Show or set self._scene_class.

        Note that this only returns the scene class; to actually
        create an *instance* of the scene class, use `scene_class()()`.
        """
        if val is not None:
            self._scene_class = val
        return self._scene_class
    def resolution(self, val=None):
        """
        Show or set self._resolution
        """
        if val is not None:
            self._resolution = val
        return self._resolution
    def file_name(self, val=None):
        """
        Show or set self._file_name
        """
        if val is not None:
            self._file_name = val
        return self._file_name
    def reset_file_name(self, image_format='.png'):
        """
        Reset self._file_name to tmp filename using given image format
        extension
        """
        self._file_name = sage.misc.misc.tmp_filename(ext=image_format)
        return self._file_name

    def scene(self):
        """
        Return scene object for this frame.
        """
        g = self.scene_class()() # instantiate scene class
        return g
    
