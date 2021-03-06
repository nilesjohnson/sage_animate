"""
Animation timeline is a Sage object which holds sequence of animation Segments

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
# This file was *autogenerated* from the file timeline.sage.
from sage.all_cmdline import *   # import sage library
from sage.misc.temporary_file import tmp_dir

from datetime import timedelta
from itertools import chain

from frame_container import FrameContainer

# helper function
def timeline(segment_obj=None,**kwds):
    """
    Wrap the given segment object in a Timeline; if no `segment_obj`
    given, just return empty timeline.  With optional keywords, update
    `general_frame_settings` of this Timeline.
    """
    T = Timeline()
    T.general_frame_settings.update(kwds)
    if segment_obj is not None:
        T._append_segment_object(segment_obj)
    return T



class Segment(FrameContainer):
    """
    Produces sequence of frames from input parameters.  frame_function
    is a function on the (time) interval [param_min, param_max] whose outputs
    are Frame objects.

    A Segment object does not have rendering information such as frame
    rate, image resolution, directory to save files in, etc.  These
    are set uniformly across multiple Segment objects with a Timeline
    object.  Without an ambient Timeline object, the frames in a
    Segment are saved with temporary (random) file names and default
    render parameters.
    
    If you just want to render a single Segment, but with more control
    over the render parameters (e.g. with sequential file names), the
    `wrap_with_timeline` method produces a Timeline object wrapping a
    Segment object.  You can supply render parameters as keywords to
    `wrap_with_timeline`, or adjust the resulting Timeline object at a
    later time.
    """
    def __init__(self, name, frame_function, num_frames, param_min=0, param_max=1, first_frame=0):
        FrameContainer.__init__(self)
        self._name = name
        self.frame_function = frame_function
        self._param_min = param_min
        self._param_max = param_max

        self._timeline = None

        # update FrameContainer values
        self.first_frame(first_frame)
        self.last_frame(first_frame + num_frames - 1)

    def __repr__(self):
        return "Animation segment: {0};  {1} frames. [{2} -- {3}]".format(self.name(),self.num_frames(),self.first_frame(),self.last_frame())
    def __str__(self):
        return self.name()
    def __add__(self,other):
        """
        This function is called to get the value of self + other.
        Note that this operation is neither commutative nor
        associative.
        """
        return self.wrap_with_timeline() + other
        
    def __call__(self,n):
        """
        return frame number n, where n is in range(num_frames).
        """
        if not n in self.frame_range():
            raise IndexError("requested frame number is not in this segment")
        t = self.param_min() + (n-self.first_frame())*(self.param_max() - self.param_min())/self.num_frames()
        F = self.frame_function(t)

        if self._timeline is not None:
            F.update(self._timeline.general_frame_settings) # update with general settings from Timeline
            F.update({'file_name':self._timeline.frame_file_name(n)}) # update file name
        return F
    # def __getitem__(self,n):
    #     """
    #     alias for self.__call__
    #     """
    #     return self(n)

    # show or set attributes
    def frames_generator(self,step_size=1):
        """
        Generator for frames in this segment
        """
        return (self(n) for n in self.frame_range()[::step_size])
    def name(self,val=None):
        """
        show or set self._name
        """
        if val is not None:
            self._name = val
        return self._name
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

    def wrap_with_timeline(self,**kwds):
        """
        Return Timeline object containing this Segment.  Additional
        keywords are passed to the `general_frame_settings` of the
        Timeline.
        """
        return timeline(copy(self),**kwds)
    

class Timeline(FrameContainer):
    """
    The class which holds our animation data as a sequence of Segment
    objects.

    A Timeline object sets the rendering parameters for all of its
    constituent Segment objects.  The `render_*` methods render a
    batch of frames in parallel, using Sage's parallel decorator.

    Segments can be added to a Timeline object in two ways: the
    `add_segment` method generates a new Segment and appends it to the
    Timeline.  An existing Segment can be added with the
    `_append_segment_object` method or with the `+` operator (a
    shorthand).  Segment objects themselves can be added with `+`,
    resulting in a Timeline object containing the two Segments.

    Note that `+` is neither commutative nor associative; the
    right-hand Segment comes after the left-hand Segment or Timeline
    in the resulting Timeline.
    """
    def __init__(self):
        FrameContainer.__init__(self) # generic frame attributes

        # general settings for Frames in this Timeline
        self.general_frame_settings['out_dir']=tmp_dir()
        self.general_frame_settings['image_format']='.png'
        self.general_frame_settings['frame_name']='animation-frame'
        self.general_frame_settings['resolution']=(544,306)

        # attributes of this Timeline;
        # each of the values in this block can be shown or set with a
        # corresponding non-underscore method
        self._segment_class = Segment
        self._frame_rate = 30 # frames per second
        self._high_quality = False # in the default configuration, this has no effect

        self._segments = tuple()

    def __repr__(self):
        """
        print self
        """
        msg = "An animation timeline with {0} segments.  Duration {1} sec.".format(len(self._segments),self.duration())
        return msg

    def __add__(self,other):
        """
        Append Segment object to self

        This function is called to get the value of self + other.
        Note that this operation is neither commutative nor
        associative.
        """
        try:
            name = other.name()
            new = copy(self)
            new._append_segment_object(copy(other))
            return new

        except AttributeError:
            raise AttributeError('other summand does not appear to be Segment object')

    # show or set general frame settings 
    def out_dir(self, val=None):
        """
        Show or set self.general_frame_settings['out_dir']
        out_dir should include trailing slash.
        """
        if val is not None:
            # make sure that trailing slash is included by rstripping and then adding it
            self.general_frame_settings['out_dir'] = val.rstrip('/')+'/'
        return self.general_frame_settings['out_dir']
    def reset_out_dir(self):
        """
        Reset output directory to temporary directory
        """
        name = tmp_dir()
        return self.out_dir(name)
    def image_format(self, val=None):
        """
        Show or set self.general_frame_settings['image_format'] with
        leading dot as in '.png', '.jpg', etc.
        """
        if val is not None:
            if val[0] == '.':
                self.general_frame_settings['image_format'] = val
            else:
                self.general_frame_settings['image_format'] = '.'+val
        return self.general_frame_settings['image_format']
    def frame_name(self, val=None):
        """
        Show or set self.general_frame_settings['frame_name']
        """
        if val is not None:
            self.general_frame_settings['frame_name'] = val
        return self.general_frame_settings['frame_name']
    def resolution(self, val=None):
        """
        Show or set self.general_frame_settings['resolution']
        """
        if val is not None:
            self.general_frame_settings['resolution'] = val
        return self.general_frame_settings['resolution']

    # show or set other attributes
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
    def high_quality(self, val=None):
        """
        Show or set self._high_quality
        """
        if val is not None:
            self._high_quality = val
        return self._high_quality
    def ncpus(self,val=None):
        """
        Show or set self._ncpus
        """
        if val is not None:
            self.save_frame.parallel.p_iter.ncpus = val
        return self.save_frame.parallel.p_iter.ncpus

    def duration(self):
        """
        total duration of this animation
        """
        return timedelta(seconds=float(self.num_frames()/self.frame_rate()))

    def frame_time(self,n):
        """
        the time at which frame number n occurs (or would occur; this
        function does not verify that n is one of the frame numbers of
        this animation)
        """
        d = float(n - self.first_frame())/float(self.frame_rate())
        hms = timedelta(seconds=int(d))
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

    def add_segment(self, name, frame_function, duration, **kwds):
        """
        Add new segment using self.segment_class; number of frames is
        computed from `frame_rate`, rounded to nearest integer.
        """
        num_frames = round(duration*self.frame_rate())
        segment_class = self.segment_class()
        S = segment_class(name=name, 
                          frame_function=frame_function,
                          num_frames=num_frames,
                          **kwds)
        self._append_segment_object(S)

    def _append_segment_object(self,S):
        """
        append a segment object to self, adjusting frame numbers of S
        and setting S._timeline to self
        """
        first_frame = self.next_frame()
        num_frames = S.num_frames()
        S.first_frame(first_frame)
        S.last_frame(first_frame + num_frames - 1)
        
        S._timeline = self
        self._segments += (S,)
        self.last_frame(S.last_frame())
        
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
        raise IndexError('requested frame number not in this timeline')

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
        frames = (S(n) for n in frame_numbers) 
        to_render = self.save_frame(frames) # uses generator instead of list
        for x in to_render:
            verbose("  ..finished {0}".format(x[0][0][0]))
        return None

    def all_frames(self,step_size=1):
        """
        generator for all frames in this animation
        """
        seg_frames = (S.frames_generator(step_size=step_size) for S in self._segments)
        return chain(*seg_frames)
            

    def render_frames(self,frame_range):
        """
        Run `self.save_frame` on a list of frame numbers.
        """
        print "rendering {2} frames {0} -- {1}".format(frame_range[0],frame_range[-1],len(frame_range))
        print "saving to {0}".format(self.out_dir())
        to_render = self.save_frame(frame_range)
        for x in to_render:
            verbose("  ..finished {0}".format(x[0][0][0]))
        print "Finished! Frames in {0}".format(self.out_dir())
        return None

    def render_all(self,**kwds):
        """
        Render all frames of this animation, passing keywords to `render_segment`
        """
        print "rendering {0} frames".format(self.num_frames())
        print "saving to {0}".format(self.out_dir())
        frames = self.all_frames(**kwds)
        to_render = self.save_frame(list(frames)) # uses generator instead of list
        for x in to_render:
            verbose("  ..finished {0}".format(x[0][0][0]))
        
        print "Finished with all frames! Frames in {0}".format(self.out_dir())

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

    def presave(self,*args,**kwds):
        pass
    @parallel
    def save_frame(self,F,*args,**kwds):
        """
        Save image of frame object F.  If F is an integer, get frame number F from
        this animation.

        args and kwds are passed to Scene object
        """
        self.presave(F,*args,**kwds)
        verbose('saving frame image..')
        try:
            g = F.scene(*args,**kwds)
        except AttributeError:
            F = self.frame(F)
            g = F.scene(*args,**kwds)
        g.save(F.file_name())







