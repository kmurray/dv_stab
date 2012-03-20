#ifndef CALCMOTIONVECTOR_H
#define CALCMOTIONVECTOR_H

Solution calcMotionVector(CorrelatorModule* correlator_ptr);

void calcLocalMotionVectors(Solution BestSolns[], CorrelatorModule* correlator_ptr);

Solution median(Solution solns[], int size);

void selectionSort(Solution solns[], int size);

void swap(Solution solns[], int pos, int pos_min);

#endif
