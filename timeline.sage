"""
Animation timeline is a Sage object which holds sequence of animation Segments

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
from datetime import timedelta
load('segment.sage')

#class NewAnimate(SageObject):
class Timeline(SageObject):
    """
    The class which holds our animation data as a sequence of Segment objects.
    """
    def __init__(self):
        # each of the values in this block can be shown or set with a
        # corresponding non-underscore method
        self._segment_class = Segment
        self._frame_rate = 30 # frames per second
        self._resolution = (544, 306) # 544 x 306 is same aspect ratio as 1920 x 1080
        self._image_format = '.png'
        self._frame_name = "animation-frame"
        self._first_frame = 0
        self._high_quality = False # in the default configuration, this has no effect
        self._out_dir = sage.misc.misc.tmp_dir()

        self._segments = []

    def __repr__(self):
        """
        print self
        """
        msg = "An animation.  Duration %s sec."%(self.duration())
        return msg

    # show or set attributes
    def segment_class(self, val=None):
        """
        Show or set self._segment_class
        """
        if val is not None:
            self._segment_class = val
        return self._segment_class
    def frame_rate(self, val=None):
        """
        Show or set self._frame_rate
        """
        if val is not None:
            self._frame_rate = val
        return self._frame_rate
    def resolution(self, val=None):
        """
        Show or set self._resolution
        """
        if val is not None:
            self._resolution = val
        return self._resolution
    def image_format(self, val=None):
        """
        Show or set self._image_format with leading dot as in '.png', '.jpg', etc.
        """
        if val is not None:
            if val[0] == '.':
                self._image_format = val
            else:
                self._image_format = '.'+val
        return self._image_format
    def frame_name(self, val=None):
        """
        Show or set self._frame_name
        """
        if val is not None:
            self._frame_name = val
        return self._frame_name
    def first_frame(self, val=None):
        """
        Show or set self._first_frame
        """
        if val is not None:
            self._first_frame = val
        return self._first_frame
    def high_quality(self, val=None):
        """
        Show or set self._high_quality
        """
        if val is not None:
            self._high_quality = val
        return self._high_quality
    def out_dir(self, val=None):
        """
        Show or set self._out_dir
        Trailing slash will be stripped away.
        """
        if val is not None:
            self._out_dir = val.rstrip('/')
        return self._out_dir
    def reset_out_dir(self):
        """
        Reset output directory to temporary directory
        """
        name = sage.misc.misc.tmp_dir()
        return self.out_dir(name)


    def duration(self):
        """
        total duration of this animation
        """
        return timedelta(seconds=float(self.num_frames()/self.frame_rate()))

    def num_frames(self):
        """
        total number of frames in this animation
        """
        return sum(S.num_frames() for S in self._segments)

    def next_frame(self):
        """
        return next frame number (successor to largest frame number defined so far)
        """
        try:
            return self._segments[-1].next_frame()
        except IndexError:
            return self.first_frame()
    def frame_time(self,n):
        """
        the time at which frame number n occurs (or would occur; this
        function does not verify that n is one of the frame numbers of
        this animation)
        """
        from datetime import timedelta as tdelta
        d = (n - self.first_frame())/self.frame_rate()
        hms = tdelta(seconds=int(d))
        return str(hms)+'.%03d'%(1000*(d-int(d))) #just show seconds to two decimal places
    
    def segment(self,i):
        """
        return ith segment object.
        """
        return self._segments[i]
    
    def show_segments(self):
        """
        show segment names, frame numbers, and timing
        """
        for i,S in enumerate(self._segments):
            ff = S.first_frame()
            lf = S.last_frame()
            print "({2}) {3}: {0} -- {1}".format(ff,lf,i,S.name())
            print "  %s -- %s"%(self.frame_time(ff),self.frame_time(lf))

    def add_segment(self, name, frame_function, duration):
        """
        Add new segment using self.segment_class; number of frames is
        computed from `frame_rate`, rounded to nearest integer.
        """
        first_frame = self.next_frame()
        num_frames = round(duration*self.frame_rate())
        segment_class = self.segment_class()
        S = segment_class(name=name, 
                          frame_function=frame_function,
                          num_frames=num_frames, 
                          first_frame=first_frame)
        self._segments.append(S)

    def frame(self,n):
        """
        Return frame number n; this just tries to return S(n) for each
        segment S until it succeeds.  Maybe there is a better way to
        get the nth frame.
        """
        for S in self._segments:
            try:
                return S(n)
            except IndexError:
                pass
    def frame_file_name(self,n):
        return self.out_dir()+"{0:08d}".format(n)+self.image_format()

    def render_segment(self,S,step_size=1):
        """
        Render frames in given segment, or every kth frame where step_size = k.

        S can be a segment object, or an integer.  If given an
        integer, render the segment given by `segment`(S).  See
        `show_segments` for a list of segments in this animation.
        """
        try:
            frame_numbers = S.frame_range()[::step_size]
        except AttributeError:
            S = self.segment(S)
            frame_numbers = S.frame_range()[::step_size]
            
        print "rendering {2} frames {0} -- {1}".format(S.first_frame(),S.last_frame(),S.num_frames())
        print "saving to {0}".format(self.out_dir())
        def frames(): 
            for n in frame_numbers:
                F = S(n)
                F.file_name(self.frame_file_name(n))
                yield F
        to_render = self.save_frame(frames()) # uses generator instead of list
        for x in to_render:
            verbose("  ..finished frame {0}".format(x[0][0][0]))
        print "Done! Frames in {0}".format(self.out_dir())
        return None

    def render_frames(self,frame_range):
        """
        Run `self.save_frame` on a list of frame numbers.
        """
        print "rendering {2} frames {0} -- {1}".format(frame_range[0],frame_range[-1],len(frame_range))
        print "saving to {0}".format(self.out_dir())
        to_render = self.save_frame(frame_range)
        for x in to_render:
            verbose("  ..finished frame {0}".format(x[0][0][0]))
        print "Done! Frames in {0}".format(self.out_dir())
        return None

    def show_frame(self,F,*args,**kwds):
        """
        Show image of frame object F.  If F is an integer, get frame number F from
        this animation.

        args and kwds are passed to Scene object
        """
        verbose('saving frame image..')
        try:
            g = F.scene(*args,**kwds)
        except AttributeError:
            g = self.frame(F).scene(*args,**kwds)
        g.show()

    @parallel
    def save_frame(self,F,*args,**kwds):
        """
        Save image of frame object F.  If F is an integer, get frame number F from
        this animation.

        args and kwds are passed to Scene object
        """
        verbose('saving frame image..')
        try:
            g = F.scene(*args,**kwds)
        except AttributeError:
            F = self.frame(F)
            g = F.scene(*args,**kwds)
        g.save(F.file_name())







