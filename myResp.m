function [f,W]=myResp(w,NB)
N=length(w);
W = fft(w, NB);
f = linspace(0, 1, NB);