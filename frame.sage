"""
Animation Frame is a Sage object which produces an image from a Scene object.

AUTHORS: Niles Johnson (2013) <http://www.nilesjohnson.net>

#*****************************************************************************
#                  Copyright (C) 2013 by AUTHORS
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 3 of
#  the License, or (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

"""
from os.path import basename

class Frame(SageObject):
    """
    Object to store data for Scene object
    """
    def __init__(self,**custom_settings):
        # default settings defined as a dictionary so they can be set
        # in batch by FrameContainer
        self.settings = {}
        self.settings['scene_class'] = Scene
        self.settings['resolution'] = (544,306)
        self.settings['image_format'] = '.png'
        # update with custom settings from FrameContainer
        self.update(custom_settings)


    def __repr__(self):
        return basename(self.file_name())
    def update(self,custom_settings):
        """
        update dict of settings
        """
        self.settings.update(custom_settings)
            
    def scene_class(self,val=None):
        """
        Show or set self.settings['scene_class'].

        Note that this only returns the scene class; to actually
        create an *instance* of the scene class, use `scene_class()()`.
        """
        if val is not None:
            self.settings['scene_class'] = val
        return self.settings['scene_class']
    def resolution(self, val=None):
        """
        Show or set self.settings['resolution']
        """
        if val is not None:
            self.settings['resolution'] = val
        return self.settings['resolution']
    def image_format(self, val=None):
        """
        Show or set self.settings['image_format']
        """
        if val is not None:
            self.settings['image_format'] = val
        return self.settings['image_format']
    def file_name(self, val=None):
        """
        Show or set self.settings['file_name']
        """
        if val is not None:
            self.settings['file_name'] = val
        try:
            return self.settings['file_name']
        except KeyError:
            return self.file_name(sage.misc.misc.tmp_filename(ext=self.image_format()))
    def reset_file_name(self, image_format='.png'):
        """
        Reset self._file_name to tmp filename using given image format
        extension
        """
        return self.file_name(sage.misc.misc.tmp_filename(ext=image_format))

    def scene(self):
        """
        Return scene object for this frame.
        """
        g = self.scene_class()() # instantiate scene class
        return g
    def show(self,*args,**kwds):
        """
        show Scene object
        """
        self.scene().show(*args,**kwds)
    def save(self,*args,**kwds):
        """
        Render and save image of scene object as `self.file_name`;
        return self.file_name.  To override default file name, use
        keyword `filename`.
        """
        try:
            name = kwds['filename']
        except KeyError:
            name = self.file_name()
            kwds['filename'] = name
        self.scene().save(*args,**kwds)
        return name
    


class Scene(Tachyon):
    """
    Stores information of 3D scene.  This class is just a placeholder for your own subclasses.
    """
