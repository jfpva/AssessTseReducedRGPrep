AssessTseReducedRGPrep
======================

Assess MRI TSE reduced receiver gain preparation experiment data.

The receiver gain optimisation step of the preparation phase of a TSE sequence on Philips scanner (version R3) takes as long as one dynamic of the actual scan. 
This is as a result of the acquisition of TSE-specific receiver corrections for every slice in the stack.

The reduced receiver gain prep patch collects a subset of slices during the receiver gain preparation and estimates TSE corrections for the skipped slices.

To assess performance of the patch, collect T2 anatomical data using the TSE sequence using the patch with full and reduced receiver gain preparations to assess performance of the reduced prep feature.

For usage, see [example.m](https://github.com/jfpva/AssessTseReducedRGPrep/blob/master/example.m).