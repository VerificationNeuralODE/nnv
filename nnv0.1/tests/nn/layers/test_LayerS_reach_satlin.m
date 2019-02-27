I = ExamplePoly.randVrep;   % input set
W = [1.5 1; 0 0.5];
b = [0.5; 0.5];
L = LayerS(W, b, 'satlin');

V = [0 0; 1 0; 0 1];
I = Star(V', I.A, I.b);

I1 = I.affineMap(W, b);

figure;
I.plot;

figure;
I1.plot;


S = L.reach(I, 'star'); % new Layer class
figure;
Star.plots(S);



