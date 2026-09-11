using Nemo

# 1. Configurar el campo no arquimediano
# Usaremos los números 2-ádicos. 
# Le damos una precisión de 300 porque las iteraciones polinomiales consumen precisión rápidamente.
R = PadicField(2, 300)

# 2. Definir el parámetro lambda con |lambda|_2 > 1
# Elegimos lambda = 1/2. Su valuación 2-ádica es -1, por lo que su norma es 2 > 1.
lam = R(1) // R(2)

# 3. La función racional (polinomial en este caso)
phi(z) = z^2 + lam * z

# 4. Función para identificar en qué disco (símbolo) cae el punto
function simbolo(z, lam)
    # Disco 0: D(0, 1) -> |z|_p <= 1 lo que equivale a v_p(z) >= 0
    if valuation(z) >= 0
        return 0
    # Disco 1: D(-lambda, 1) -> |z + lambda|_p <= 1 lo que equivale a v_p(z + lam) >= 0
    elseif valuation(z + lam) >= 0
        return 1
    else
        # Si no está en ninguno, el punto escapó al conjunto de Fatou (V)
        return -1 
    end
end

# 5. Motor de iteración para generar el itinerario h(z)
function calcular_itinerario(z, lam, iteraciones)
    itinerario = Int[]
    z_actual = z
    
    for i in 1:iteraciones
        s = simbolo(z_actual, lam)
        push!(itinerario, s)
        
        if s == -1
            println("El punto escapó al conjunto de Fatou en la iteración $i")
            break
        end
        
        # Iterar la función
        z_actual = phi(z_actual)
    end
    
    return itinerario
end

# --- COMPROBACIÓN DEL ISOMORFISMO SHIFT ---

function verificar_isomorfismo_shift(lam)
    # Definimos puntos estratégicos que sabemos que pertenecen al conjunto de Julia.
    # Recordando que A = D(0, 1) U D(-lam, 1)
    puntos = [
        ("Punto fijo 0 (Símbolo 0)", R(0)),
        ("Punto fijo 1-λ (Símbolo 1)", R(1) - lam),
        ("Preimagen exacta z = -λ", -lam),
        ("Preimagen exacta z = -1", R(-1))
    ]
    
    println("\n=== Verificando h(φ(z)) = σ(h(z)) ===")
    
    for (nombre, z_test) in puntos
        println("\n-> Evaluando: $nombre")
        
        # 1. Calculamos el itinerario original h(z)
        it_z = calcular_itinerario(z_test, lam, 10)
        println("Itinerario h(z):    ", it_z)
        
        # Verificamos que el punto realmente pertenezca a J(φ) (que no escape a Fatou)
        if -1 ∉ it_z
            # 2. Calculamos la imagen φ(z)
            z_img = phi(z_test)
            
            # 3. Calculamos el itinerario de la imagen h(φ(z)) con un paso menos
            it_img = calcular_itinerario(z_img, lam, 9)
            println("Itinerario h(φ(z)): ", it_img)
            
            # 4. Comparamos el shift descartando el primer símbolo de h(z)
            shift_exitoso = it_z[2:end] == it_img
            println("¿Shift exitoso?:    ", shift_exitoso)
        else
            println("El punto escapó al conjunto de Fatou.")
        end
    end
end

# Ejecutamos la función
verificar_isomorfismo_shift(lam)

using Random

# --- GENERACIÓN DE PUNTOS CAÓTICOS (Ramas Inversas) ---
function generar_puntos_julia(lam, num_puntos, profundidad)
    nuevos_puntos = []
    
    for i in 1:num_puntos
        # Partimos de un punto que sabemos que está en J(φ) (el repulsor 0)
        z_actual = R(0) 
        
        for _ in 1:profundidad
            # Aplicamos la fórmula general: z = (-λ ± sqrt(λ^2 + 4*z_actual)) / 2
            discriminante = lam^2 + R(4) * z_actual
            
            # Gracias a tu Teorema 4.6 y 5.6, sabemos teóricamente que esta raíz existe en A
            raiz_disc = sqrt(discriminante)
            
            z_opcion1 = (-lam + raiz_disc) // R(2)
            z_opcion2 = (-lam - raiz_disc) // R(2)
            
            raices = [z_opcion1, z_opcion2]
            
            # Elegimos una rama inversa al azar para adentrarnos en el fractal
            z_actual = raices[rand(1:2)]
        end
        push!(nuevos_puntos, ("Punto Caótico $i", z_actual))
    end
    
    return nuevos_puntos
end

# Generamos 10 puntos aplicando 500 iteraciones inversas aleatorias
puntos_caoticos = generar_puntos_julia(lam, 10, 500)

println("\n=== Verificando el Shift para Puntos Caóticos ===")
for (nombre, z_test) in puntos_caoticos
    println("\n-> Evaluando: $nombre")
    
    # Calculamos 10 pasos del itinerario para ver la secuencia mezclada
    it_z = calcular_itinerario(z_test, lam, 10)
    println("Punto generado: ", z_test)
    println("Itinerario h(z):    ", it_z)
    
    if -1 ∉ it_z
        z_img = phi(z_test)
        it_img = calcular_itinerario(z_img, lam, 9)
        println("Itinerario h(φ(z)): ", it_img)
        
        # Verificamos la conmutatividad h(φ(z)) = σ(h(z))
        shift_exitoso = it_z[2:end] == it_img
        println("¿Shift exitoso?:    ", shift_exitoso)
    else
        println("El punto escapó a Fatou.")
    end
end 
