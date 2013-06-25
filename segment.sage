"""
Animation Segment is a Sage object which produces sequence of Frames from input parameters

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

class Segment(SageObject):
    """
    Produces sequence of frames from input parameters.  frame_function
    is a function on the (time) interval [param_min, param_max] whose outputs
    are Frame objects.
    """
    def __init__(self, name, frame_function, num_frames, param_min=0, param_max=1, first_frame=0):
        self._name = name
        self._num_frames = num_frames
        self.frame_function = frame_function
        self._param_min = param_min
        self._param_max = param_max
        self._first_frame = first_frame
    def __repr__(self):
        return "Animation segment: {0};  {1} frames.".format(self.name(),self.num_frames())
    def __call__(self,n):
        """
        return frame number n, where n is in range(num_frames).
        """
        if not n in self.frame_range():
            raise IndexError("requested frame number is not in this segment")
        t = self.param_min() + n*(self.param_max() - self.param_min())/self.num_frames()
        F = self.frame_function(t)
        return F
    # def __getitem__(self,n):
    #     """
    #     alias for self.__call__
    #     """
    #     return self(n)

    # show or set attributes
    def name(self,val=None):
        """
        show or set self._name
        """
        if val is not None:
            self._name = val
        return self._name
    def num_frames(self,val=None):
        """
        show or set self._num_frames
        """
        if val is not None:
            self._num_frames = val
        return self._num_frames
    def param_min(self,val=None):
        """
        show or set self._param_min
        """
        if val is not None:
            self._param_min = val
        return self._param_min
    def param_max(self,val=None):
        """
        show or set self._param_max
        """
        if val is not None:
            self._param_max = val
        return self._param_max
    def first_frame(self,val=None):
        """
        show or set self._first_frame
        """
        if val is not None:
            self._first_frame = val
        return self._first_frame

    def frame_range(self):
        return range(self.first_frame(), self.first_frame() + self.num_frames())

    def next_frame(self):
        return self.first_frame() + self.num_frames()

    def last_frame(self):
        return self.next_frame() - 1


