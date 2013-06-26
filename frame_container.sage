"""
Generic container for frames.

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
class FrameContainer(SageObject):
    """
    Generic container for frames; the Timeline and Segment classes are
    both subclasses of FrameContainer.

    Set attributes which should be the same for all frames in a
    given segment or animation.  Frames are assumed to be sequentially
    numbered starting with first_frame.

    The only attributes set at this level should be those which both
    Timeline *and* Segment objects should have.
    """
    def __init__(self):
        self.general_frame_settings = {}
        
        # attributes of the FrameContainer itself
        self._first_frame=0
        self._last_frame=None
    def __repr__(self):
        return 'Frame container with general settings '+repr(self.general_frame_settings)
    def update(self,custom_settings):
        """
        batch update `general_frame_settings`
        """
        self.general_frame_settings.update(custom_settings)

    # methods to show or set specific settings
    def first_frame(self, val=None):
        """
        Show or set self_first_frame
        """
        if val is not None:
            self._first_frame = val
        return self._first_frame
    def last_frame(self, val=None):
        """
        Show or set self._last_frame
        """
        if val is not None:
            self._last_frame = val
        return self._last_frame

    # other methods computed from settings
    def next_frame(self):
        """
        successor to self.last_frame()
        """
        try:
            return self.last_frame() + 1
        except TypeError: # when self.last_frame() is None
            return self.first_frame()
    def num_frames(self, val=None):
        """
        number of frames in this container
        """
        try:
            return self.last_frame() - self.first_frame() + 1
        except TypeError: # when self.last_frame() is None
            return 0
    def frame_range(self):
        return range(self.first_frame(), self.next_frame())
    def frame_file_name(self,n):
        """
        Frame file name is determined by `out_dir`, `frame_name`, `n`, and `image_format`
        """
        return self.out_dir()+self.frame_name()+"{0:08d}".format(n)+self.image_format()
