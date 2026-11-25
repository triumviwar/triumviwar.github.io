"""(crown-micro, docs/crown_micro.md) compare bench arms: python3 tools/study/crown_micro_bench_cmp.py BASE[+BASE2] ARM ...
(the arms are docs/crown_micro/bench/<name>.json, written by tools/bench_crown_micro.gd out:...)"""
import json,sys,math,os
DIR=os.path.join(os.path.dirname(os.path.abspath(__file__)),'../../docs/crown_micro/bench')
def load(spec):
    rs=[]
    for n in spec.split('+'):
        try: rs+=json.load(open(os.path.join(DIR,n+'.json')))['runs']
        except FileNotFoundError: pass
    return rs
def stats(rs):
    x=[r['score'] for r in rs]; n=len(x); m=sum(x)/n
    v=sum((a-m)**2 for a in x)/max(1,n-1); return n,m,v
B=load(sys.argv[1]); nb,mb,vb=stats(B)
def per(rs):
    d={}
    for r in rs: d.setdefault(r['sc'],[]).append(r['score'])
    return {k:sum(v)/len(v) for k,v in d.items()}
pb=per(B)
print("%-22s n %3d score %+.3f k/l %.2f won %d" % (sys.argv[1],nb,mb,sum(r['killed'] for r in B)/sum(r['lost'] for r in B),sum(r['score']>0 for r in B)))
for spec in sys.argv[2:]:
    A=load(spec)
    if not A: print(spec,"none"); continue
    n,m,v=stats(A); se=math.sqrt(v/n+vb/nb)
    print("%-22s n %3d score %+.3f diff %+.3f (t %+.2f) k/l %.2f won %d" % (spec,n,m,m-mb,(m-mb)/se,sum(r['killed'] for r in A)/max(1,sum(r['lost'] for r in A)),sum(r['score']>0 for r in A)))
    pa=per(A); print("    "+" ".join("%s %+.2f"%(k,pa[k]-pb.get(k,0)) for k in pa))
