classdef Symbol
    %Symbol A linear combination of messages
    
    properties
        v_coeffs;
        val;
        msg_inds;
    end
    
    methods
        function obj = Symbol(v_coeffs, msg_vals, msg_inds)         
            obj.v_coeffs = v_coeffs;
            obj.val = dot(v_coeffs,msg_vals);
            obj.msg_inds = msg_inds;
        end
    end
    
end

