using JuMP
import Ipopt
using LinearAlgebra
using Plots
#using HiGHS
using GLPK

function matriz_carga(num_tm,p_carga_ve)
    ## Matriz de permutacion
    M = zeros(num_tm,num_tm)
    for t = 1:num_tm-1
        M[t,t+1] = 1
    end 
    M[num_tm,1] = 1

    M_carga = zeros(num_tm,num_tm)
    Mh = I
    for t = 1:num_tm        
        M_carga[:,t] = Mh*p_carga_ve        
        Mh = Mh*M
    end
    return M_carga
end

#model = Model(GLPK.Optimizer)
# Variables del sistema
num_tm = 24   # numero total de pasos de discretización
num_ve = 3    # número total de vehiculos eléctricos
p_trafo = 25  # potencia del transformador

p_carga_ve = zeros(num_tm,1)
p_carga_ve[1] = 11
p_carga_ve[2] = 10
p_carga_ve[3] = 5
p_carga_ve[4] = 3


M_carga = matriz_carga(num_tm,p_carga_ve)

#Variables de desición 


#Restriciones


#Función Objetivo

