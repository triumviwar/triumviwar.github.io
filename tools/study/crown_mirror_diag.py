#!/usr/bin/env python3
"""CROWN MIRROR COACH (docs/crown_mirror_coach.md): behaviour counts from the logs of crown_mirror_coach.py batches (waves, pull-backs,
the press, the target, the guns, the hunt; the side ahead at 15:00). A measuring tool.
    python3 tools/study/crown_mirror_diag.py DIR [DIR2 ...]"""
import json,glob,re,os,sys
for D in sys.argv[1:]:
    tot=dict(waves=0,late_waves=0,pull_wall=0,recall=0,press=0,held=0,target=0,guns=0,shell=0,hunt=0)
    lw=[];lh=[]
    for f in sorted(glob.glob(D+'/*/log.txt')):
        if os.path.getsize(os.path.dirname(f)+'/result.json')==0: continue
        log=open(f,errors='replace').read(); r=json.load(open(os.path.dirname(f)+'/result.json'))
        w=re.findall(r"\[(\d\d):(\d\d)\] P(\d) Crown's (?:first attack goes out|wave \d+ goes out|siege push: goes out)",log)
        tot['waves']+=len(w); tot['late_waves']+=sum(1 for m,s,p in w if int(m)>=10)
        tot['pull_wall']+=len(re.findall(r"pulls back from the (gate|palisade)",log))
        tot['recall']+=len(re.findall(r"calls its wave home",log))
        tot['press']+=len(re.findall(r"presses its lead",log))
        tot['held']+=len(re.findall(r"pressed wave is held",log))
        tot['target']+=len(re.findall(r"wave goes for the enemy hall",log))
        tot['guns']+=len(re.findall(r"to shell the enemy's walled hall",log))
        tot['shell']+=len(re.findall(r"holds its line out of reach and shells",log))
        tot['hunt']+=len(re.findall(r"Crown hunts",log))
        fin={x['p']:x for x in r['final']}; sc=lambda x:x['income']+2*x['army']
        if r['winner']<0:
            L=0 if sc(fin[0])>1.1*sc(fin[1]) else 1 if sc(fin[1])>1.1*sc(fin[0]) else -1
            if L>=0:
                lw.append(sum(1 for m,s,p in w if int(m)>=10 and int(p)==L+1))
                lh.append(sum(1 for e in r['events'] if e['ev']=='hall_lost' and e['p']==1-L))
    print(D, tot, 'leaders %d: waves after 10:00 mean %.2f (none in %d); halls taken mean %.2f (none in %d)'%(len(lw),sum(lw)/len(lw),lw.count(0),sum(lh)/len(lh),lh.count(0)))
