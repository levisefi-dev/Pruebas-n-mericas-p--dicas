using Hecke

p = 5
R = PadicField(p, 300)
Rx, z = polynomial_ring(R, "z")
φ(z) = (z^p - z) / p

raices_unidad = [teichmuller(R(k)) for k in 1:(p-1)]

println("Raíces (p-1)-ésimas de la unidad en Q_$p:")
for r in raices_unidad
    println(r)
end

println("\nVerificación (deben dar 1):")
for r in raices_unidad
    println(r^(p-1))
end

function simbol(z)
    if valuation(z) >= 1
        return 0
    end
    for (i, r) in enumerate(raices_unidad)
        if valuation(z - r) >= 1
            return i
        end
    end
    return -1   # no debería alcanzarse si {0}∪{raíces} cubre Z_p mod p
end

function itinerario(z, n)
    itinerario = []
    for i in 1:n
        push!(itinerario, simbol(z))
        z = φ(z)
    end
    return itinerario
end

for r in push!(raices_unidad, R(0))
    println("\n=== Evaluando: z = $r ===")
    println("Itinerario h(z): ", itinerario(r, 10))
    println("Itinerario h(φ(z)): ", itinerario(φ(r), 10))
    println("¿Shift exitoso?: ", itinerario(r, 10)[2:end] == itinerario(φ(r), 10)[1:end-1])
end

using Random

function generar_puntos_julia(num_puntos, num_iteraciones)
    campo = base_ring(Rx)   # el campo REAL sobre el que vive Rx, sin ambigüedad
    nuevos_puntos = []
    for i in 1:num_puntos
        z_actual = campo(0)
        for j in 1:num_iteraciones
            w = campo(z_actual)          # fuerza la coerción explícita al campo correcto
            poly = z^p - z - campo(p)*w
            raices = roots(poly)
            if isempty(raices)
                break   # o `continue`, según qué comportamiento prefieras
            end
            z_actual = raices[rand(1:length(raices))]
        end
        push!(nuevos_puntos, ("Punto Caótico $i", z_actual))
    end
    return nuevos_puntos
end

puntos_caoticos = generar_puntos_julia(10, 500)

println("\n=== Verificando el Shift para Puntos Caóticos ===")
for (nombre, z_test) in puntos_caoticos 
    # Calculamos 10 pasos del itinerario para ver la secuencia mezclada
    it_z = itinerario(z_test, 10)
    println("Punto generado: ", z_test)
    println("Itinerario h(z):    ", it_z)
    
    if -1 ∉ it_z
        z_img = φ(z_test)
        it_img = itinerario(z_img, 9)
        println("Itinerario h(φ(z)): ", it_img)
        
        # Verificamos la conmutatividad h(φ(z)) = σ(h(z))
        shift_exitoso = it_z[2:end] == it_img
        println("¿Shift exitoso?:    ", shift_exitoso)
    else
        println("El punto escapó a Fatou.")
    end
end 