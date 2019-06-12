classdef Conv2DLayer < handle
    % The convolutional 2D layer class
    %   Contain constructor and reachability analysis methods
    % Main references:
    % 1) An intuitive explanation of convolutional neural networks: 
    %    https://ujjwalkarn.me/2016/08/11/intuitive-explanation-convnets/
    % 2) More detail about mathematical background of CNN
    %    http://cs231n.github.io/convolutional-networks/
    % 3) Matlab implementation of Convolution2DLayer (for training and evaluating purpose)
    %    https://www.mathworks.com/help/deeplearning/ug/layers-of-a-convolutional-neural-network.html
    %    https://www.mathworks.com/help/deeplearning/ref/nnet.cnn.layer.convolution2dlayer.html
    
    %   Dung Tran: 12/5/2018
    
    properties
        Name = 'convolutional_layer';
        % Hyperparameters
        FilterSize = []; % height and width of filters
        NumChannels = 'auto';
        NumFilters = 0; % number of filters
        Stride = [1 1]; % step size for traversing input
        DilationFactor = [1 1]; % factor for dilated convolution
        PaddingMode = 'manual';
        PaddingSize = [0 0 0 0]; % size of padding [t b l r] for nonnegative integers
        
        % Learnable Parmeters/ Used for reachability analysis
        Weights = [];
        Bias = [];
    end
    
    
    % setting hyperparameters method
    methods
        
        % constructor of the class
        function obj = Conv2DLayer(varargin)           
            % author: Dung Tran
            % date: 12/5/2018    
            % update: 
            
            switch nargin
                
                case 6
                    
                    layer_name = varargin{1}; 
                    filter_weights = varargin{2};
                    filter_bias = varargin{3};
                    padding_mat = varargin{4};
                    stride_mat = varargin{5};
                    dilation_mat = varargin{6};
                    
                    if ischar(layer_name)
                        obj.Name = layer_name;
                    else
                        error('Layer name should be a char array');
                    end
                    
                    
                    w = size(filter_weights);
                    b = size(filter_bias);
                    
                    if length(w) ~= 4
                        error('Invalid weights array');
                    end
                    if length(b) ~= 3
                        error('Invalid biases array');
                    end

                    if w(4) ~= b(3)
                        error('Inconsistency between filter weights and filter biases');
                    end
                    
                    obj.NumFilters = w(4);
                    obj.NumChannels = w(3);
                    obj.FilterSize = [w(1) w(2)];
                    obj.Weights = filter_weights;
                    obj.Bias = filter_bias;
                                        
                    p = size(padding_mat);
                   
                    if  length(p) ~= 2 || p(2) ~= 4|| p(1) ~= 1
                        error('Invalid padding matrix');
                    end
                    obj.PaddingSize = padding_mat;
                    
                    s = size(stride_mat);
                    if length(s) ~= 2 || s(1) ~= 1
                        error('Invalid stride matrix');
                    end
                    obj.Stride = stride_mat;
                    
                    d = size(dilation_mat);
                    if length(d) ~= 2 || d(1) ~= 1
                        error('Invalid dilation matrix');
                    end                
                    obj.DilationFactor = dilation_mat;
                    
                    
                
                case 5
                    
                    filter_weights = varargin{1};
                    filter_bias = varargin{2};
                    padding_mat = varargin{3};
                    stride_mat = varargin{4};
                    dilation_mat = varargin{5};
                    
                    obj.Name = 'convolutional_layer';                   
                    
                    w = size(filter_weights);
                    b = size(filter_bias);
                    
                    if length(w) ~= 4
                        error('Invalid weights array');
                    end
                    if length(b) ~= 3
                        error('Invalid biases array');
                    end

                    if w(4) ~= b(3)
                        error('Inconsistency between filter weights and filter biases');
                    end
                    
                    obj.NumFilters = w(4);
                    obj.NumChannels = w(3);
                    obj.FilterSize = [w(1) w(2)];
                    obj.Weights = filter_weights;
                    obj.Bias = filter_bias;
                    
                    p = size(padding_mat);
                    if length(p) ~= 4 || p(1) ~= 1
                        error('Invalid padding matrix');
                    end
                    obj.PaddingSize = padding_mat;
                                               
                    s = size(stride_mat);
                    if length(s) ~= 2 || s(1) ~= 1
                        error('Invalid stride matrix');
                    end
                    obj.Stride = stride_mat;
                    
                    d = size(dilation_mat);
                    if length(d) ~= 2 || d(1) ~= 1
                        error('Invalid dilation matrix');
                    end                
                    obj.DilationFactor = dilation_mat;                   
                    
                    
                case 2
                    
                    filter_weights = varargin{1};
                    filter_bias = varargin{2};
                                        
                    obj.Name = 'convolutional_layer';                   
                    
                    w = size(filter_weights);
                    b = size(filter_bias);
                    
                    if length(w) ~= 4
                        error('Invalid weights array');
                    end
                    if length(b) ~= 3
                        error('Invalid biases array');
                    end

                    if w(4) ~= b(3)
                        error('Inconsistency between filter weights and filter biases');
                    end
                    
                    obj.NumFilters = w(4);
                    obj.NumChannels = w(3);
                    obj.FilterSize = [w(1) w(2)];
                    obj.Weights = filter_weights;
                    obj.Bias = filter_bias;
                    
                    % use default setting for Stride, Padding and Dilation
                    obj.Stride = [1 1]; % step size for traversing input
                    obj.DilationFactor = [1 1]; % factor for dilated convolution
                    obj.PaddingMode = 'manual';
                    obj.PaddingSize = [0 0 0 0]; % size of padding [t b l r] for nonnegative integers
        
                                    
                otherwise
                    error('Invalid number of inputs (should be 2, 5, or 6)');
                                 
            end
                    
                
            
            
            
            
             
        end
        
        % set stride method 
        function set_stride(obj, stride)
            % @stride: stride matrix
            % author: Dung Tran
            % date: 12/5/2018
            
            [n, m] = size(stride);
            
            if n ~= 1
                error('Stride matrix shoule have one row');
            end
            
            if m == 1
                obj.Stride = [stride stride];
            elseif m == 2
                obj.Stride = [stride(1) stride(2)];
            elseif m ~=1 && m ~=2 
                error('Invalide stride matrix');
            end
            
        end
        
        
        % set dilation factor
        function set_dilation(obj, dilation)
            % @dilation: dilation matrix
            % author: Dung Tran
            % date: 12/5/2018
            
            [n, m] = size(dilation);
            
            if n ~= 1
                error('Dilation matrix shoule have one row');
            end
            
            if m == 1
                obj.DilationFactor = [dilation dilation];
            elseif m == 2
                obj.DilationFactor = [dilation(1) dilation(2)];
            elseif m ~=1 && m ~=2 
                error('Invalide dilation matrix');
            end
            
        end
        
        % set padding 
        function set_padding(obj, padding)
            % @padding: padding matrix
            % author: Dung Tran
            % date: 12/5/2018
            
            [n, m] = size(padding);
            
            if n ~= 1
                error('Padding matrix shoule have one row');
            end
            
            if m == 1
                obj.PaddingSize = [padding padding padding padding];
            elseif m == 4
                obj.PaddingSize = [padding(1) padding(2) padding(3) padding(4)];
            elseif m ~=1 && m ~=4 
                error('Invalide padding matrix');
            end
        end
        
        % set weights and biases
        function set_weights_biases(obj, weights, biases)
            % @weights: a 4-dimensional array
            %  = FilterSize(1)-by-FilterSize(2)-by-NumChannels-by-NumFilter
            % @biases: a 3-dimensional array
            %  = 1-by-1-by-NumFilters 
            
            w = size(weights);
            b = size(biases);
            
            if length(w) ~= 4
                error('Invalid weights array');
            end
            if length(b) ~= 3
                error('Invalid biases array');
            end
            
            if w(4) ~= b(3)
                error('Inconsistency between weights and biases');
            end
            
            if w(4) ~= obj.NumFilters
                fprintf('\nInconsistency between weights and biases and number of filters parameter');
                fprintf('\nNumber of filters is updated from %d to %d', obj.NumFilters, w(4));
            end
            obj.NumFilters = w(4);
            
            obj.Weights = weights;
            obj.Bias = biases;
            
        end
        
        % set name of this layer
        function set_name(obj, name)
            % @name: name of this layer
            
            % author: Dung Tran
            % date: 12/5/2018
            
            if ischar(name)
                obj.Name = name;
            else
                error('Input is not a character array');
            end
            
        end
        
    end
    
    
    % evaluation method
    methods
        
        function y = evaluate(obj, input)
            % @input: 3-dimensional array, for example, input(:, :, :)
            % @y: high-dimensional array (output volume), depth of output = number of filters
            
            % author: Dung Tran
            % date: 12/10/2018
            
            
            n = size(input);
            w = size(obj.Weights);
            
            if length(n) ~= 3
                error('Input should be a 3-dimensional array');
            end
            
            if w(3) ~= n(3) % number of channels need to be consistent
                error('Inconsistency between weights/biases and input');
            end
            
            y = zeros(w(1),w(2), w(4)); % preallocate 3D matrix
            for i=1:w(4) % number of filters
                y(:, :, i) = obj.Bias(:, :, i) * ones(w(1), w(2)); % initialize output by bias matrix
                % compute feature map with i^th filter 
                for j=1:w(3) % filter for j^th channel of input 
                    W1 = obj.Weights(:,:,j, i);   
                    I1 = input(:, :, j); % the j^th input channel
                    if j==1
                        y(:, :, i) = Conv2DLayer.compute_featureMap(I1, W1, obj.PaddingSize, obj.Stride, obj.DilationFactor);
                    else
                        y(:, :, i) = y(:, :, i) + Conv2DLayer.compute_featureMap(I1, W1, obj.PaddingSize, obj.Stride, obj.DilationFactor);
                    end                    
                end
                [ny, my] = size(y(:, :, i));
                y(:, :, i) = y(:, :, i) + obj.Bias(:, :, i) * ones(ny, my);                               
            end
                   
        end
        
        % parallel evaluation on an array of inputs
        function y = evaluate_parallel(obj, inputs)
            % @inputs: an array of inputs
            % @y: an array of outputs 
            
            % author: Dung Tran
            % date: 12/16/2018
            y = [];
            parfor i=1:length(inputs)
                y = [y obj.evaluate(inputs(i))];               
            end
            
            
        end
        
    end
    
    
    
    methods(Static) % parsing, get zero input pading, compute feature maps
        
        % parse a trained convolutional2dLayer from matlab
        function L = parse(conv2dLayer)
            % @conv2dLayer: a convolutional 2d layer from matlab deep
            % neural network tool box
            % @L : a Cov2DLayer for reachability analysis purpose
            
            % author: Dung Tran
            % date: 12/5/2018
            
            
            if ~isa(cov2dLayer, 'convolution2dLayer')
                error('Input is not a Matlab convolution2dLayer class');
            end
            
            L = Conv2DLayer(conv2dLayer.FilterSize, conv2dLayer.NumFilters);
            L.set_stride(conv2dLayer.Stride);
            L.set_dilation(conv2dLayer.DilationFactor);
            L.set_padding(conv2dLayer.PaddingSize);
            L.set_weights_biases(conv2dLayer.Weights, conv2dLayer.Bias);
            
            fprintf('Parsing a Matlab convolutional 2d layer is done successfully');
            
        end
        
        % parse input image with padding
        function I = get_zero_padding_input(input, paddingSize)
            % @input: an array of input image, 1 or high-dimensional array
            % @paddingSize: paddingSize to construct the new input I
            % @I: the new input array affer applying padding
            
            % author: Dung Tran
            % date: 12/10/2018
            
            n = size(input);        
            if length(paddingSize) ~= 4
                error("\Invalid padding size");
            end
            
            t = paddingSize(1);
            b = paddingSize(2);
            l = paddingSize(3);
            r = paddingSize(4);
 
            
            if length(n) == 2 
                % input volume has only one channel                
                h = n(1); % height of input
                w = n(2); % width of input 
                      
                I = zeros(t + h + b, l + w + r);
                I(t+1:t+h,l+1:l+w) = input; % new constructed input volume
                
            elseif length(n) > 2
                % input volume may has more than one channel
                            
                h = n(1); % height of input
                w = n(2); % width of input 
                d = n(3); % depth of input (number of channel)
               
                I = zeros(t + h + b, l + w + r, d); % preallocate 3D matrix
                for i=1:d
                    I(t+1:t+h, l+1:l+w, i) = input(:, :, i); % new constructed input volume
                end              
                
                
            else
                error('Invalid input');
            end
                         
        end
        
        
        % compute feature map for specific input and weight
        function featureMap = compute_featureMap(input, W, padding, stride, dilation)
            % @input: is input 
            % @W: is a weight matrix (filter)
            % @padding: zero-padding size
            % @stride: step size for traversing input
            % @dilation: factor for dilated convolution     
            % @featureMap: convolved feature (also called feature map)
            
            
            % author: Dung Tran
            % date: 12/10/2018
            
            % referece: 1) https://ujjwalkarn.me/2016/08/11/intuitive-explanation-convnets/
            %           2) https://www.mathworks.com/help/deeplearning/ug/layers-of-a-convolutional-neural-network.html
            
            
            I = Conv2DLayer.get_zero_padding_input(input, padding);
            n = size(I); % n(1) is height and n(2) is width of input
            m = size(W); % m(1) is height and m(2) is width of the filter
            
            % I, W is 2D matrix
            % I is assumed to be the input after zero padding
            % output size: 
            % (InputSize - (FilterSize - 1)*Dilation + 1)/Stride
            
            h = floor((n(1) - (m(1) - 1) * dilation(1) - 1) / stride(1) + 1);  % height of feature map
            w = floor((n(2) - (m(2) - 1) * dilation(2) - 1) / stride(2) + 1);  % width of feature map

            % a collection of start points (the top-left corner of a square) of the region of input that is filtered
            map = cell(h, w); 
            
            for i=1:h
                for j=1:w
                    map{i, j} = zeros(1, 2);

                    if i==1
                        map{i, j}(1) = 1;
                    end
                    if j==1
                        map{i, j}(2) = 1;
                    end

                    if i > 1
                        map{i, j}(1) = map{i - 1, j}(1) + stride(1);
                    end

                    if j > 1
                        map{i, j}(2) = map{i, j - 1}(2) + stride(2);
                    end

                end
            end
            
            % compute feature map for each cell of map
            % do it in parallel using cpu or gpu
            % TODO: explore power of using GPU for this problem
            
            featureMap = zeros(1, h*w); % using single vector for parallel computation
           

            for l=1:h*w
                a = mod(l, w);
                if a == 0
                    i = floor(l/w);
                    j = w;
                else
                    j = a;
                    i = floor(l/w) + 1;
                end

                % get a filtered region
                val = 0;
                i0 = map{i, j}(1);
                j0 = map{i, j}(2);

                ie = i0;
                je = j0;
                for i=1:m(1)
                    for j=1:m(2)
                        if ie <= n(1) && je <= n(2)
                            val = val + I(ie, je) * W(i, j);
                        end
                        je = je + dilation(2);
                    end
                    je = j0;
                    ie = ie + dilation(1);
                end

                featureMap(1,l) = val;

            end

            featureMap = reshape(featureMap, [h, w]);
            featureMap = featureMap.';

        end

        
    end
    
    
    
    % reachability analysis using star set
    
    methods
        % reachability analysis method using Stars
        % a star represent a set of images (2D matrix of h x w)
        function S = reach_star_single_input(obj, input)
            % @inputs: an ImageStar input set
            % @option: = 'single' single core for computation
            %          = 'parallel' multiple cores for parallel computation
            % @S: an imagestar with number of channels = obj.NumFilters
            
            % author: Dung Tran
            % date: 6/11/2019
            
            if ~isa(input, 'ImageStar')
                error('The input is not an ImageStar object');
            end
            
            if input.numChannel ~= obj.NumChannels
                error("Input set contains %d channels while the convolutional layers has %d channels", input.numChannel, obj.NumChannel);
            end
            
            % compute output sets           
            Y = cell(obj.NumFilters, 1); % output basis matrices
            for i=1:obj.NumFilters
                Y{i} = cell(1, input.numPred + 1);
            end
            
            I(:, :, input.numChannel) = zeros(input.height, input.width); % pre-allocate memory
            for i=1:input.numPred + 1
                for j=1:input.numChannel
                    I(:,:,j) = input.V{j}{i};
                end
                
                Z = obj.evaluate(I);
                
                for k=1:obj.NumFilters
                    Y{k}{i} = Z(:, :, k);
                end
                
            end
            
            S = ImageStar(Y, input.C, input.d, input.pred_lb, input.pred_ub);
                    
        end
    end
    
end

