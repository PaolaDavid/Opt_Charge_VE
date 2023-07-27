##################################################
### Optimización carga de vehiculos eléctricos ###
### Por:  Alejandro Garcés                     ###
### Version: 1.0                               ###
### Fecha:  19 julio de 2023                   ###
##################################################

using HiGHS
using JuMP
using LinearAlgebra
using Plots

# Matriz carga vehiculos
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

model = Model(HiGHS.Optimizer)
# Variables del sistema
num_tm = 24*4   # numero total de pasos de discretización
num_ve = 5      # número total de vehiculos eléctricos
p_trafo = 20    # potencia del transformador

@variable(model, p[1:num_tm,1:num_ve] >= 0)
@variable(model, costo[1:num_ve])
@variable(model, z[1:num_tm,1:num_ve], binary=true)


## Modelo de costos (me invente una funcion, pero en realidad se deben tomar los datos de XM)
c = [370*round(sin(2*t/num_tm),digits=1) for t = 1:num_tm]


# Modelo de carga del vehiculos (me invente una funcion pero se debe tomar los datos de VE reales)
p_carga_ve = zeros(num_tm,1)
for t=1:16
    p_carga_ve[t+19*4] = 11*round(cos(pi*t/16/2),digits=1)
end


## Funcion objetivo
@objective(model, Min, sum(costo))

M_carga = matriz_carga(num_tm,p_carga_ve)
## restricciones
for t = 1:num_tm    
    for k = 1:num_ve
        @constraint(model, z[t,k] <= 1)
        @constraint(model, z[t,k] >= 0)
    end    
end

for k = 1:num_ve        
    @constraint(model, p[:,k] .== M_carga*z[:,k])    
    @constraint(model, costo[k] == sum(c.*p[:,k]))
end

for k = 1:num_ve
    @constraint(model, sum(z[:,k]) == 1)
end

for t = 1:num_tm
    @constraint(model, sum(p[t,:]) <= p_trafo)
end

optimize!(model)
p_ve = zeros(num_tm,num_ve)
z_ve = zeros(num_tm,num_ve)
for k = 1:num_ve
   for t = 1:num_tm
        p_ve[t,k] = value(p[t,k])
        z_ve[t,k] = value(z[t,k])
   end
end
## Graficar resultados
tiempo = 1/4*(1:num_tm)
plt_costo = plot(tiempo,c, label = "Precio de bolsa (COP/kWh)")
plot_ve = plot(tiempo,p_ve)
plot(plt_costo,plot_ve,layout = grid(2, 1))