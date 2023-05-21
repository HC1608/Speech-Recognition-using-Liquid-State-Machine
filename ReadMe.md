##Check out mp4 file and docx file for more details

data.m generated the dataset stored in TI-dataset.mat

preprocessing.m generates 77 channel input spikes data using TI-dataset.mat, which contains the raw speakers data, and stores it into preprocessing.mat.

raster.m takes a digit as input (0-9) and plots the raster plot for all speakers.

connections.m generates the input and reservoir (250 = 10*5*5 neurons) connectivity matrices and stores it in connections.mat.

RR.m generates the temporal reservoir response using preprocessing.mat and connections.mat and LIF neuron models.

TT.m performs 5-fold training and testing using the reservoir response and generates classification accuracy.

mix.m performs training on mixed pitches and testing on a particular pitch.

cross.m performs training on one pitch and testing on other pitch (randomly).
