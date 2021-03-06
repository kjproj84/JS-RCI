fp.query(datadep)
v = fp.get_answer();


#print colored (v, 'green')

#print v.num_args(),v.arg(0), v.arg(0).children()[0].arg(1), v.arg(0).children()[1].arg(1)
#print v.num_args(),v.arg(1)
for x in range(0, v.num_args()):
    try:
        idx0 = v.arg(x).children()[0].arg(1).as_long()
        idx1 = v.arg(x).children()[1].arg(1).as_long()
            #if idx0 !=idx1:
            #print  colored(code[idx1]+'('+str(idx1)+')->', 'blue'), colored(code[idx0]+'('+str(idx0)+')', 'blue')
    except KeyError:
        print "KeyError for "


import sys

#print "This is the name of the script: ", sys.argv[0]
#print "Number of arguments: ", len(sys.argv)
#print "The arguments are: " , str(sys.argv)

def queryDep(enter, exit):
    fp.query(datadep(BitVecVal(enter,lineNum),BitVecVal(exit,lineNum)))
    #fp.get_answer()
    return str(fp.get_answer()) == 'True'

def getDepCode(stmt):
    depcodes =[];
    #    print "getDepCode", stmt
    exitLine = Const('exit',lineNum)
    fp.declare_var(exitLine)
    fp.query(datadep(exitLine,BitVecVal(stmt,lineNum)))
    v_ex = fp.get_answer();
    #print "test", v_ex, v_ex.num_args(), len(v_ex.arg(0).children())
    if v_ex.num_args()==2 and len(v_ex.arg(0).children())!=2:
        idx =v_ex.arg(1)
        #print "222??", idx
        depcodes.append(idx)
        return depcodes
    cwd = os.getcwd()
    for x in reversed(range(0, v_ex.num_args())):
        try:
            idx = v_ex.arg(x).children()[1].as_long()
            #print(idx)
            depcodes.append(idx);
        #            print colored(code[idx], 'green')
        except KeyError:
            print "KeyError for "
    return depcodes

def getcode(id):
    return str(code[id])

def inputAdapt(stmt, loading):
    re_assign = '(.+)=(.*);'
    m=re.search(re_assign, stmt)
    if(m!=None):
        right =m.group(2)
        #        print right+"@@@"+str(str(right).find(loading))
        return str(right).find(loading)
    else:
        return -1;

def inputAdapt2(stmt):
    re_assign = '(.+)=(.*);'
    m=re.search(re_assign, stmt)
    if(m!=None):
        right =m.group(2)
        return stmt.replace(right,"input");
    else:
        return -1;


def outputAdapt(stmt, loading):
    re_assign = '(.+)=(.*);'
    m=re.search(re_assign, stmt)
    if(m!=None):
        right =m.group(2)
        #print right+"@@@"+str(str(right).find(loading))
        return str(right).find(loading)
    else:
        return -1;

def outputAdapt2(stmt, loading):
    re_assign1 = 'var (.+)=(.*);'
    re_assign = '(.+)=(.*);'
    #re_assign2 = 'var (.+)=(.*);'
    m=re.search(re_assign1, stmt)
    if(m!=None):
        right =m.group(2)
        left =m.group(1)
        if str(right).find(loading) !=-1:
            stmt.replace(right,"input")
            return stmt+"\n"+"  var output="+left+";"
        else:
            return stmt;
    else:
        return stmt;



pattern_for_require = 'require\(\'(.+)\'\)'
pattern_for_img_url = 'https?:\/\/.*\.(?:png|jpg)'

def sourcingImg(jstext):
    m1=re.search(pattern_for_img_url, jstext)
    if m1==None:
        return jstext
    i = 0
    if os.path.exists('./img'):
        while m1!=None and i<100:
            i = i+1
            matched =  m1.group(0)
            jstext = jstext.replace(matched, "img/"+str(i)+".jpg")
            #        print colored(matched,"green")
            m1=re.search(pattern_for_img_url, jstext)
        return jstext
    
    os.makedirs('./img')
    #print jstext
    i = 0
    #m1 = None
    while m1!=None and i<100:
        i = i+1
        matched =  m1.group(0)
        #        print '.'
        urllib.urlretrieve(matched, "img/"+str(i)+".jpg")
        jstext = jstext.replace(matched, "img/"+str(i)+".jpg")
        #        print colored(matched,"green")
        m1=re.search(pattern_for_img_url, jstext)
    return jstext


depstmt = [];

def getWrite1Line(id):
    exitLine = Const('exit11',lineNum)
    fp.declare_var(exitLine)
    fp.query(Write1( BitVecVal(id,var),exitLine))
    v= fp.get_answer();
    #if v.num_args() == 2:
        #        print colored (v, 'red'),  v.num_args()
        #print "getWrite1Line ",v.arg(1)
    return v.arg(1).as_long()

def getWrite1Line(id,line):
    exitLine = Const('exit11',lineNum)
    fp.declare_var(exitLine)
    
    
    #print colored(line, "red");
    fp.query(Write1( BitVecVal(id,var),exitLine))
    v= fp.get_answer();
    
    #print "@@", id, line, v,v.num_args(), len(v.arg(0).children())
    if v.num_args() == 2 and len(v.arg(0).children()) !=2:
        #        print colored (v, 'red'),  v.num_args()
        print "getWrite1Line ",v.arg(1)
        return v.arg(1).as_long()
    else:
        for i in range(v.num_args()):
            #idx = v_ex.arg(x).children()[1].as_long()
            hashline = v.arg(i).children()[1].as_long()
            #hashline = v.arg(i).children()[1].children()[1].as_long()
            checkline = oline[code[hashline]]
            #            print "else", checkline
            if line==checkline:
                return hashline

    return 0



def getRead2Line(id,line):
    vv2 = Const('vv2',var)
    fp.declare_var(vv2)
    exitLine = Const('exit',lineNum)
    fp.declare_var(exitLine)
    fp.query(Read2(BitVecVal(2,obj),vv2, exitLine))
    v=fp.get_answer();
#    print "getRead2Line", v, v.num_args()
    if  v.num_args()==2:
#        print v.arg(1).children()[1]
        return v.arg(1).children()[1].as_long()
    else:
        for i in range(v.num_args()):
            hashline = v.arg(i).children()[1].children()[1].as_long()
            checkline = oline[code[hashline]]
            #            print "else", checkline
            if line==checkline:
                return hashline
    return 0
#    print colored(v,"blue")

from slimit.parser import Parser
from slimit.visitors import nodevisitor
from slimit import ast
parser = Parser()


def adaptoutput(text, exit):
    tree = parser.parse(text)
    for node in nodevisitor.visit(tree):
        #text = "var BROKERS = require(\'./mock-brokers\').data;"
        #-> var output = text;
        if isinstance(node, ast.VarDecl) and node.identifier.value==exit:
            return "    var output="+exit+";"
        elif isinstance(node, ast.VarDecl) and node.identifier.value!=exit:
            return "    var output="+node.identifier.value+";"
    return ""

if len(sys.argv)==4:
    input_var, input_line=sys.argv[1].split(':')
    output_var, output_line=sys.argv[2].split(':')
#    print "len",input_var, input_line,output_var, output_line
    #print sys.argv, hashVar[sys.argv[1]], hashVar[sys.argv[2]], sys.argv[3]
    #entry=getWrite1Line(hashVar[sys.argv[1]])
    entry=getWrite1Line(hashVar[input_var], int(input_line))
    print "entry", entry
    #exit = getRead2Line(hashVar[sys.argv[2]],11)
    exit = getRead2Line(hashVar[output_var],int(output_line))
    print "exit", exit
    #entry =9992535;
    #exit = 8473275;
    input = 9999;
    print "dep?", queryDep(entry, exit)
    if queryDep(entry, exit):
        component = ""
        print "data-dep? Y"
        exit_dep_list=getDepCode(exit)
        print "exit_dep_list", exit_dep_list
        entry_dep_list=getDepCode(entry)
        print "entry_dep_list", entry_dep_list
        entry_dep_list.append(int(entry))
        #  print "entry_dep_list", entry_dep_list
        list = [item for item in exit_dep_list if item not in entry_dep_list]
        list = [item for item in list if item not in requires.keys()]
        #        print "l1ist", list
        indent = "  ";
        #        component = "export function component(input){";
        print colored("export function component_"+sys.argv[3]+"(input){","red")
        component = component + "export function component_"+sys.argv[3]+"(input){" +'\n'
        depstmt.append(indent+code[int(entry)]);
        for c in list:
            depstmt.append(indent+code[c]);
        
        depstmt.append(indent+code[int(exit)]);
        input_p =[];
        #input_var = sys.argv[1];
        i = 0;
        for stmt in depstmt:
            input = inputAdapt(stmt,input_var)
            if input !=-1:
                input_p.append(i);
            i = i +1;
        depstmt[input_p[0]]=inputAdapt2(depstmt[input_p[0]])
        output_p =[];
        i = 0;
        #output_var = sys.argv[2];
        for stmt in depstmt:
            output = outputAdapt(stmt,output_var)
            if output !=-1:
                output_p.append(i);
            i = i +1;
        
        depstmt[output_p[0]]=outputAdapt2(depstmt[output_p[0]],output_var)
        
        for stmt in depstmt:
            print colored(stmt, "red")
            component = component + stmt +'\n'
        
        
        for key, value in requires.iteritems():
            #            print "requires", key,",",'m'+value
            jstext ="";
            dep_req=getDepCode(key)
            dep_req = [item for item in dep_req if item not in requires.keys()]
            #print "$$", key, list, int(exit), int(entry)
            if len(dep_req)==0 and (queryDep(key, int(exit)) or queryDep(key, int(entry))):
                jstext = jstext +  '//dependent_stmt\n'+sourcingImg(code[key])
            #else:
            f = open(value, 'w')
            f.write(jstext);
        print colored(indent+"return output;", "red")
        component = component + "return output;" +'\n'
        print colored("}","red")
        component = component + "}" +'\n'
        f = open(sys.argv[3]+".js", 'w')
        f.write(component)

if len(sys.argv)==3:
    input, line=sys.argv[1].split(':')
#    print "##", input, line, hashVar[input]
    exit = getWrite1Line(hashVar[input],int(line))
    if 1==1:
        print "data-dep? Y"
        component=""
        exit_dep_list=getDepCode(exit)
        #        print "exit_dep_list", exit_dep_list
        list = [item for item in exit_dep_list if item not in requires.keys()]
        #        list = [item for item in list if item not in requires.keys()]
        indent = "  ";
        #        component = "export function component_"+sys.argv[2]+"(){";
        print colored("export function component_"+sys.argv[2]+"(){","red")
        component = component + "export function component_"+sys.argv[2]+"(){" +'\n'
        depstmt.append(indent+code[int(exit)]);
        for c in list:
            #print oline[code[c]]
            depstmt.append(indent+code[c]);
        depstmt.append(adaptoutput(code[int(exit)], sys.argv[1]));
        output_p =[];
        i = 0;
        output_var = sys.argv[2];
        for stmt in depstmt:
            output = outputAdapt(stmt,output_var)
            #print "output", output;
            if output !=-1:
                output_p.append(i);
            i = i+1;
        
        if len(output_p) > 0:
            depstmt[output_p[0]]=outputAdapt2(depstmt[output_p[0]],output_var)
                
        for stmt in depstmt:
            print colored(stmt,"red")
            component = component + stmt +'\n'
        for key, value in requires.iteritems():
            jstext ="";
            dep_req=getDepCode(key)
            #print "$$", key, list, int(exit)
            dep_req = [item for item in dep_req if item not in requires.keys()]
            if len(dep_req)==0 and (queryDep(key, int(exit))):
                jstext = jstext + '//dependent_stmt\n'+sourcingImg(code[key])
            #else:
            f = open(value, 'w')
            f.write(jstext);
        
        print colored(" return output;","red")
        component = component + " return output;" +'\n'
        print colored("}","red")
        component = component + "}"
        f = open(sys.argv[2]+".js", 'w')
        f.write(component)
