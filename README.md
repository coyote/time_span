Time Span
==========

This gem is composed of 3 classes:

* RelativeTime, which are time objects, with a link to another other Ruby Object.  They are not in any way absolute,1and relate only to other RelativeTime objects on the same TimeLine.   Many RelativeTimes can happen at the same time.  It is not possible to get a difference, as it would be meaningless.  Other comparators are implemented.
* TimeLine, is the context for RelativeTimes and TimeSpans for comparison.
* TimeSpan, which is composed of two RelativeTimes (a begining and ending time) on a TimeLine.

A *RelativeTime* has an associate Ruby Object (of any class), which should '#respond_to?(:to_s)'

A RelativeTime can occur with more than one TimeSpan, so must also keep track of the TimeLine to TimeSpan relationship.

Comparisons of any kind only make sense within a given TimeLine.

*TimeSpan*s are automatically attached to a TimeLine, but *RelativeTime*s are not.

*TimeLine*s are the only structure with even a moderate data complexity.  There is is a hash which keeps the relative position for each RelativeTime.  This structure allows more than one RelativeTime to be equal compared to other RelativeTimes.

For now, clone is disallowed, it could create an object not obeying the rules, such as a RelativeTime pointing to TimeLine not its own.

