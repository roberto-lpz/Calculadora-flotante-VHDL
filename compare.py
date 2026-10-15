import struct, sys
def f32(bits): return struct.unpack(">f", struct.pack(">I", bits))[0]
vec=[list(map(int,l.split())) for l in open("vectores.txt")]
res=[int(l,16) for l in open("resultados.txt")]
bad=0; n=0; worst=0
for (a,fa,sa,b,fb,sb,op),r in zip(vec,res):
    x=(a+fa/10000)*(-1 if sa else 1); y=(b+fb/10000)*(-1 if sb else 1)
    exp = x*y if op else x+y
    got=f32(r)
    n+=1
    if exp==0 and got==0: continue
    if abs(exp)>=2**32 and got in (float('inf'),float('-inf')): continue
    ref = max(abs(x),abs(y)) if op==0 else abs(exp)
    rel=abs(got-exp)/max(ref,1e-30)
    worst=max(worst,rel)
    if rel>1e-6:
        bad+=1
        if bad<=8: print("DIF", (a,fa,sa,b,fb,sb,op), "esperado",exp,"obtenido",got, f"{r:08X}")
print(f"{n} pruebas, {bad} fuera de tolerancia (1e-6 rel), peor error relativo {worst:.2e}")
