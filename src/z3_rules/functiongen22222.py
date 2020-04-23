exitLine = Const('exit', lineNum)
fp.declare_var(exitLine)

fp.query(unMarshal(line2, v1, 18888))
v_ex = fp.get_answer()
unmarshal_stmt = v_ex.arg(1).arg(1).as_long()
unmarshal_stmt_start = get_key(unmarshal_stmt).split(":")[1]
print colored("*********** Constraint Solving Started::::",'magenta')
print colored( "unMarshal***********",'blue'), unmarshal_stmt, unmarshal_stmt_start
#
#
fp.query(Marshal(line2, v1, 19999))
v_ex = fp.get_answer()
# print "Marshal***********  ", colored(v_ex,'blue'), v_ex


# fp.fact(Load(BitVecVal(27,var),BitVecVal(2,prop), BitVecVal(17,var),BitVecVal(16736239,lineNum)))
# fp.fact(ref2(BitVecVal(17,var),BitVecVal(2,prop), BitVecVal(1999,val)))

marshal_stmt = v_ex.arg(1).arg(1).as_long()
loadedVar = v_ex.arg(0).arg(1).as_long()
marshal_stmt_start = get_key(marshal_stmt).split(":")[1]
print colored("Marshal***********  ",'blue') , marshal_stmt, marshal_stmt_start
print "LoadedVar??  ", loadedVar
# fp.fact(Load(BitVecVal(1028,var),BitVecVal(1001,var), BitVecVal(1020,prop),BitVecVal(1027,lineNum)))


fp.query(datadep(exitLine,unmarshal_stmt))
v_ex = fp.get_answer()
# print "@@@@@@@@@@@@***********  ", v_ex


fp.query(datadep(exitLine,marshal_stmt))
v_ex = fp.get_answer()
# print "@@@@@@@@@@@@***********  ", v_ex

# fp.query(Load)
# v_ex = fp.get_answer()
# print "######################LoadOrAssignVar", v_ex

if marshal_stmt != unmarshal_stmt:
    fp.query(ExecutedStmts(exitLine, 12313, 18888, 19999))
else:
    fp.query(ExecutedStmts0(exitLine, 18888, 19999))

# fp.query(ExecutedStmts(exitLine, 12313, 18888, 19999))
v_ex = fp.get_answer()
print colored("ExecutedStmts***********  ",'blue')
print v_ex
uid = "abcDe"

jscode="//JS-RCI generated\n"

extract_ftn={};
extract_globals={};
extract_others={};

for x in range(0, v_ex.num_args()):
    myposition = get_key(v_ex.arg(x).arg(1).as_long()).split(":")[1];
    if myposition<unmarshal_stmt_start or myposition>marshal_stmt_start:
        extract_globals[myposition]= v_ex.arg(x).arg(1).as_long();
    else:
        extract_ftn[myposition]=v_ex.arg(x).arg(1).as_long();

# print "extract_ftn", extract_ftn
# print "extract_others", extract_others

print colored("Extracting Functions***********  ",'magenta')

for key in sorted(extract_globals.keys()):
    if extract_globals[key] > boundToExtractFunction:
        # print colored(code[extract_globals[key]], 'cyan')
        otherfilename = get_key(extract_globals[key]).split(":")[0]
        # print otherfilename
        if otherfilename in extract_others:
            extract_others[otherfilename].append(code[extract_globals[key]]);
        else:
            extract_others[otherfilename] = [];
            extract_others[otherfilename].append(code[extract_globals[key]]);
    else:
        print colored(code[extract_globals[key]], 'blue')
        jscode +=code[extract_globals[key]]+"\n"


# print "extract_others", extract_others
print colored("function "+uid+"(input){","yellow")
jscode +="function "+uid+"(input){"+"\n"
adaptedIn = adaptinput(code[unmarshal_stmt],"id")
print colored(adaptedIn, 'blue')
jscode +=adaptedIn+"\n"
for key in sorted(extract_ftn.keys()):
    print colored("\t" + code[extract_ftn[key]], 'yellow')
    jscode += "\t"+code[extract_ftn[key]] + "\n"

print colored(adaptoutput(code[marshal_stmt], loadedVar), 'blue')
jscode +=adaptoutput(code[marshal_stmt], loadedVar) +"\n"
print colored("\treturn output;\n}","yellow")
jscode +="\treturn output;\n}"

if os.path.isdir("./results"):
    f=open("results/"+uid+".js", "w")
    f.write(jscode)
else:
    f=open("./"+uid+".js", "w")
    f.write(jscode)

# print extract_others
for key in extract_others:
    # print key, extract_others[key]
    if os.path.isdir("./results"):
        f = open("results/"+key, "w")
    else:
        f = open("./" + key, "w")
    txt = "//JS-RCI generated\n"
    for stmt in extract_others[key]:
        txt +=stmt
    f.write(txt)
    print colored("//depenent statements in File "+key+"\n"+txt, 'cyan')

for sql in sqlstmts:
    print colored("//sql stmts "+ "\n" + sql , 'cyan')

print colored("Extracting Functions DONE!***********  \n See generated JS files in results folder, abcDe.js is entry",'magenta')