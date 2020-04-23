# -*- coding: utf-8 -*-
'''
    ported for z3 python2.7 from JS-dep;  with modified for undetected stmts
'''
from z3 import *
from termcolor import colored
import re
import os
import string
import random
import shutil
import urllib
import operator
import os

from slimit.parser import Parser
from slimit.visitors import nodevisitor
from slimit import ast
parser = Parser()

def get_key(bin):
    for key, value in hashVar.items():
         if bin == value["bin"]:
             return key



def adaptinput(text, entry):
    # print "adaptinput   ", text, "    ",entry
    tree = parser.parse(text)
    for node in nodevisitor.visit(tree):
        #text = "var BROKERS = require(\'./mock-brokers\').data;"
        #-> var output = text;
        if isinstance(node, ast.VarDecl) and node.identifier.value==entry:
            return "\tvar "+node.identifier.value+"=input;"
        elif isinstance(node, ast.VarDecl) and node.identifier.value!=exit:
            return "\tvar "+node.identifier.value+"=input;"
    return ""

def adaptoutput(text, exit):
    tree = parser.parse(text)
    for node in nodevisitor.visit(tree):
        #text = "var BROKERS = require(\'./mock-brokers\').data;"
        #-> var output = text;
        if isinstance(node, ast.VarDecl) and node.identifier.value==exit:
            return "\tvar output="+exit+";"
        elif isinstance(node, ast.VarDecl) and node.identifier.value!=exit:
            return "\tvar output="+node.identifier.value+";"
    return ""


def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))


#z3 Fixedpoint Engine
fp = Fixedpoint()
fp.set(engine='datalog')

lineNum     = BitVecSort(24)
num         = BitVecSort(24)
var         = BitVecSort(24)
val         = BitVecSort(24)
mval        = BitVecSort(24)
obj         = BitVecSort(24)
prop        = BitVecSort(24)
jsfiles     = BitVecSort(24)
value       = BitVecSort(24)
evType      = BitVecSort(24)
uid         = BitVecSort(24)

Assign = Function('Assign', var, var, lineNum,  BoolSort()) # a = b # Assign (variable variable line#)
Load = Function('Load', var, prop, var, lineNum,  BoolSort())#; a.b = c #(declare-rel Load (var prop var lineNum))

#store,  a = b.c;
Store = Function('Store', var, var, prop, lineNum,  BoolSort()) #(declare-rel Store (var var prop lineNum))
Read1 = Function('Read1', var, lineNum,  BoolSort()) #(declare-rel Read1 (var lineNum))
Read2 = Function('Read2', var, prop, lineNum,  BoolSort()) #(declare-rel Read2 (var prop lineNum))
Write1 = Function('Write1', var, lineNum,  BoolSort()) #(declare-rel Write1 (var lineNum))
Write2 = Function('Write2', var, prop, lineNum,  BoolSort())#(declare-rel Write2 (var prop lineNum))
PtsTo = Function('PtsTo', var, obj, BoolSort()) #(declare-rel PtsTo (var obj))
HeapPtsTo = Function('HeapPtsTo', var, prop, obj, BoolSort())#(declare-rel HeapPtsTo (var prop obj))

#; Stmt (line# object)
#(declare-rel Stmt (lineNum obj))

fp.register_relation(Assign)
fp.register_relation(Store)
fp.register_relation(Load)
fp.register_relation(PtsTo)
fp.register_relation(HeapPtsTo)
fp.register_relation(Read1)
fp.register_relation(Read2)
fp.register_relation(Write1)
fp.register_relation(Write2)

Stmt        = Function('Stmt', lineNum, obj, BoolSort()) #(declare-rel Stmt (lineNum obj))
Formal      = Function('Formal', obj, num, var, BoolSort())#(declare-rel Formal (obj num var))
Actual      = Function('Actual', lineNum, num, var, BoolSort())#(declare-rel Actual (lineNum num var))
MethodRet   = Function('MethodRet', obj, var, BoolSort())#(declare-rel MethodRet(obj var))
CallRet     = Function('CallRet', lineNum, var, BoolSort())#(declare-rel CallRet (lineNum var))
Calls       = Function('Calls', obj, lineNum, BoolSort())#(declare-rel Calls (obj lineNum))

FuncDecl    = Function('FuncDecl',var, obj, lineNum, BoolSort())#(declare-rel FuncDecl (var obj lineNum))
Heap        = Function('Heap',var, obj, BoolSort())#(declare-rel Heap (var obj))
datadep     = Function('datadep',lineNum, lineNum, BoolSort()) #; data-dep (line# line#) #(declare-rel data-dep (lineNum lineNum))
controldep  = Function('controldep',lineNum, lineNum, BoolSort()) #; con-dep (line# line#) #(declare-rel control-dep (lineNum lineNum))
stmtdep     = Function('stmtdep',lineNum, lineNum, BoolSort()) #; stmt-dep (line# line#)#(declare-rel stmt-dep (lineNum lineNum))
calldep     = Function('calldep',var, var, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))

ref         = Function('ref',var, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
ref2         = Function('ref2',var, prop, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
refs         = Function('refs',lineNum, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))

unMarshal   = Function('unMarshal',lineNum, var, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
Marshal     = Function('Marshal',lineNum, var, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))

ExecutedStmts    = Function('ExecutedStmts',lineNum, uid, mval, val, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
ExecutedUid    = Function('ExecutedUid',lineNum, uid, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
ExecutedStmts0    = Function('ExecutedStmts0',lineNum, uid, mval, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))
ExecutedUMarshal    = Function('ExecutedUMarshal',lineNum, uid, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))


fp.register_relation(Stmt)
fp.register_relation(Formal)
fp.register_relation(Actual)
fp.register_relation(MethodRet)
fp.register_relation(CallRet)
fp.register_relation(Calls)
fp.register_relation(FuncDecl)
fp.register_relation(Heap)
fp.register_relation(datadep)
fp.register_relation(controldep)
fp.register_relation(stmtdep)
fp.register_relation(calldep)
fp.register_relation(ref)
fp.register_relation(ref2)
fp.register_relation(refs)

fp.register_relation(unMarshal)
fp.register_relation(Marshal)
fp.register_relation(ExecutedStmts)
fp.register_relation(ExecutedUid)
fp.register_relation(ExecutedStmts0)
o1 = Const('o1',obj)
o2 = Const('o2',obj)
o3 = Const('o3',obj)
o4 = Const('o4',obj)

v1 = Const('v1',var)
v2 = Const('v2',var)
v3 = Const('v3',var)
v4 = Const('v4',var)
v5 = Const('v5',var)
v6 = Const('v6',var)

val1 = Const('val1',val)
val2 = Const('val2',val)

line1 = Const('line1',lineNum)
line2 = Const('line2',lineNum)
line3 = Const('line3',lineNum)
line4 = Const('line4',lineNum)

i1 = Const('i1',num)
f1 = Const('f1',prop)
f2 = Const('f2',prop)


uid1 = Const('uid1',uid)

#pointsTo rule
#(rule (=> (Heap v1 o1) (PtsTo v1 o1)))
#(rule (=> (and (Heap B A)) (PtsTo B A)))
fp.register_relation(PtsTo,Heap)
fp.declare_var(v1,o1)
fp.rule(PtsTo(v1,o1),Heap(v1,o1))

fp.register_relation(PtsTo,FuncDecl)
fp.declare_var(v1,o1,line1)
fp.rule(PtsTo(v1,o1),FuncDecl(v1,o1,line1))

fp.register_relation(PtsTo,PtsTo,Assign)
fp.declare_var(v1,line1,v2)
fp.rule(PtsTo(v2,o1),[PtsTo(v1,o1),Assign(v2,v1, line1)])

#fp.register_relation(PtsTo,Assign,Assign)
#fp.declare_var(v1,line1,v2)
#fp.rule(PtsTo(v2,o1),[PtsTo(v1,o1),Assign(v2,v1, line1)])

# Stmt rule
fp.register_relation(Stmt,calldep,Stmt)
fp.declare_var(line1,o2,o1)
fp.rule(Stmt(line1,o1),[Stmt(line1,o2),calldep(o1,o2)])

# (rule (=> (and (PtsTo A B) (Actual C #x000000 A)) (Calls B C)))
fp.register_relation(Calls,Actual,PtsTo)
fp.declare_var(line1,o1,v1)
fp.rule(Calls(o1,line1),[PtsTo(v1,o1),Actual(line1,0,v1)])
#fp.rule(Calls(o1,line1),[Actual(line1,0,v1),PtsTo(v1,o1)])

fp.register_relation(Calls,Formal,Actual)
fp.declare_var(line1,o1,v1,i1,v2)
fp.rule(Assign(v1,v2,line1),[Calls(o1,line1),Formal(v1,i1, o1),Actual(line1,i1, v2)])

fp.register_relation(Assign,Calls,Formal,Actual)
fp.declare_var(v1,v2,line1,o1,i1,v2)
fp.rule(Assign(v1,v2,line1),[Calls(o1,line1),Formal(v1,i1, o1),Actual(line1,i1, v2)])


fp.register_relation(Read1,Calls,Formal,Actual)
fp.declare_var(v1,v2,line1,o1,i1,v2)
#fp.rule(Read1(v2,line1),[Calls(o1,line1),Formal(v1,i1, o1),Actual(line1,i1, v2)])
fp.rule(Read1(v2,line1),[Actual(line1,0, v1), Actual(line1,i1, v2)])

fp.register_relation(Write1,Calls,Formal,Actual)
fp.declare_var(v1,v2,line1,o1,i1,v2)
fp.rule(Write1(v1,line1),[Calls(o1,line1),Formal(v1,i1, o1),Actual(line1,i1, v2)])


fp.register_relation(Read1,Calls,Actual)
fp.declare_var(v1,v2,line1,o1,i1,v2)
fp.rule(Read1(v2,line1),[Calls(o1,line1),Actual(line1,i1, v2)])


fp.register_relation(Write1,Calls,Actual)
fp.declare_var(v1,v2,line1,o1,i1,v2)
fp.rule(Write1(v1,line1),[Calls(o1,line1),Actual(line1,i1, v2)])


fp.register_relation(Assign,Calls,MethodRet,CallRet)
fp.declare_var(v1,v2,line1,o1,i1,v2)
fp.rule(Assign(v2,v1,line1),[Calls(o1,line1),MethodRet(o1,v1),CallRet(line1,v2)])


fp.register_relation(Read1,Calls,MethodRet,CallRet)
fp.declare_var(v1,v2,line1,o1,v2)
fp.rule(Read1(v1,line1),[Calls(o1,line1),MethodRet(o1,v1),CallRet(line1,v2)])


fp.register_relation(Write1,Calls,MethodRet,CallRet)
fp.declare_var(v1,v2,line1,o1,v2)
fp.rule(Write1(v1,line1),[Calls(o1,line1),MethodRet(o1,v1),CallRet(line1,v2)])


fp.register_relation(datadep,Write1,Read1)
fp.declare_var(line1,line2,v1)
fp.rule(datadep(line1,line2),[Write1(v1,line1),Read1(v1,line2)])


fp.register_relation(unMarshal,Write1,ref)
fp.declare_var(line1,v1,val1)
fp.rule(unMarshal(line1, v1, val1),[Write1(v1,line1),ref(v1, val1)])


fp.register_relation(unMarshal,refs)
fp.declare_var(line1,v1,val1)
fp.rule(unMarshal(line1, 0, val1),refs(line1, val1))


# fp.query(datadep(BitVecVal(1, lineNum),exitLine))

#Executed    = Function('Executed',lineNum, uid, BoolSort()) #; call-dep (variable variable) #(declare-rel call-dep (var var))


fp.register_relation(Marshal,Write1,ref)
fp.declare_var(line1,v1,val1,f1)
fp.rule(Marshal(line1, v1, val1),[Write1(v1,line1),ref(v1, val1)])
# fp.rule(Marshal(line1, v1, val1),[Read2(v1,f1,line1),ref2(v1, f1, val1)])

# fp.register_relation(Marshal,Read1,ref, Read2, ref2)
# fp.declare_var(line1,v1,val1,f1)
# fp.rule(Marshal(line1, v1, val1),[Read1(v1,line1),ref(v1, val1)])
# fp.rule(Marshal(line1, v1, val1),[Read2(v1,f1,line1),ref2(v1, f1, val1)])

# fp.fact(Read2(BitVecVal(2,prop),BitVecVal(17,var),BitVecVal(16736239,lineNum)))
# fp.fact(ref2(BitVecVal(17,var),BitVecVal(2,prop), BitVecVal(1999,val)))

fp.register_relation(ExecutedStmts,datadep,unMarshal, Marshal)
fp.declare_var(line1,line2,line3, v1,val1,uid1, val2, v2)
# fp.query(datadep(BitVecVal(1, lineNum),exitLine), Not(datadep(BitVecVal(3, lineNum),exitLine)))

fp.rule(ExecutedStmts(line1, uid1, val1, val2),
        [
             datadep(line1,line2), Marshal(line2, v1, val2),
             Not(datadep(line1,line3)), unMarshal(line3, v2, val1)
        ])

fp.register_relation(ExecutedStmts0,datadep, Marshal)
fp.declare_var(line1,line2, v1,val1,uid1)
fp.rule(ExecutedStmts0(line1, uid1, val1), (datadep(line1,line2), Marshal(line2, v1, val1)))


# fp.rule(Executed(line1, uid1, val1, val2),
#         [
#              datadep(line2,line1), unMarshal(line2, v1, val1),
#              Not(datadep(line3,line1)), unMarshal(line3, v2, val2)
#         ])


# fp.query(
#              datadep(line1,line2), Marshal(line2, v1, 1999),
#              Not(datadep(line1,line3)), unMarshal(line3, v2, 1888)
#         )

fp.register_relation(ExecutedUid,datadep,unMarshal, Marshal)
fp.declare_var(line1,line2,line3, v1,val1,uid1, val2, v2)
fp.rule(ExecutedUid(line1, uid1),
        [
             datadep(line2,line1), unMarshal(line2, v1, val1),
             Not(datadep(line3,line1)), Marshal(line3, v2, val2)
        ])


fp.register_relation(datadep,Load,Read2)
fp.declare_var(line1,line2,v1,v2,o1,f1)
fp.rule(datadep(line1,line2),[Load(v1,f1,v2,line1),Read2(o1,v1,line2)])

fp.register_relation(datadep,Write1,Read2)
fp.declare_var(line1,line2,v1,f1)
fp.rule(datadep(line1,line2),[Write1(v1,line1),Read2(v1,f1,line2)])


fp.register_relation(datadep,Assign,Read2)
fp.declare_var(line1,line2,v1,o1,o2)
fp.rule(datadep(line1,line2),[Assign(v1,o1,line1),Read2(o2,v1,line2)])


fp.register_relation(datadep,Load,Read2)
fp.declare_var(line1,line2,v1,v2,f1,f2)
fp.rule(datadep(line1,line2),[Load(v1,f1,v2,line1),Read2(v1,f2,line2)])


fp.register_relation(datadep,Write2,Read1,PtsTo)
fp.declare_var(line1,line2,v1,f1,o1,v2)
fp.rule(datadep(line1,line2),[Write2(v1,f1,line1),Read1(v1,line1),PtsTo(v1,o1),PtsTo(v2,o1)])

fp.register_relation(datadep,Write2,Read2)
fp.declare_var(line1,line2,v1,f1,o1,v2)
fp.rule(datadep(line1,line2),[Write2(v1,f1,line1),Read2(v1,f1,line2)])


fp.register_relation(datadep,Write1,Write1)
fp.declare_var(line1,line2,o1)
fp.rule(datadep(line1,line2),[Write1(o1,line1),Write1(o1,line2)])
'''
    fp.rule(datadep(line1,line2),[Write2(v1,f1,line1),Read2(v1,f1,line2)])
    fp.rule(datadep(line1,line2),[Write2(v1,f1,line1),Read2(v1,f1,line2),PtsTo(v1,o1),PtsTo(v2,o1)])
    fp.rule(datadep(line1,line3),[datadep(line1,line2),datadep(line2,line3)])
    '''

fp.register_relation(controldep,stmtdep)
fp.declare_var(line1,line2)
fp.rule(stmtdep(line1,line2),controldep(line1,line2))

fp.register_relation(stmtdep,datadep)
fp.declare_var(line1,line2)
fp.rule(datadep(line1,line2),stmtdep(line1,line2))

fp.register_relation(controldep,Actual,FuncDecl)
fp.declare_var(v1,o1,line1,line2)
fp.rule(controldep(line1,line2),[Actual(line1,BitVecVal(0,num), v1), FuncDecl(v1,o1,line2)])

fp.register_relation(controldep,controldep)
fp.declare_var(line1,line2,line3)
fp.rule(controldep(line1,line3),[controldep(line1,line2),controldep(line2,line3)])


fp.register_relation(controldep,datadep)
fp.declare_var(line1,line2)
fp.rule(controldep(line1,line2),datadep(line1,line2))

# fp.register_relation(datadep,datadep)
# fp.declare_var(line1,line2)
# fp.rule(datadep(line1,line2),datadep(line2,line1))



# fp.register_relation(controldep,stmtdep)
# fp.declare_var(line1,line2)
# fp.rule(stmtdep(line1,line2),controldep(line1,line2))

# fp.register_relation(stmtdep,datadep)
# fp.declare_var(line1,line2)
# fp.rule(datadep(line1,line2),stmtdep(line1,line2))

fp.register_relation(datadep,datadep)
fp.declare_var(line1,line2,line3)
fp.rule(datadep(line1,line3),[datadep(line1,line2),datadep(line2,line3)])

code={};
hashVar={};
requires={};
oline={};
globals={};
lines={};
ranges={};
sqlstmts=[];

#VariableDecl: var dummyvar1=\"sfasfasf\";
code[1000]="var dummyvar1=\"sfasfasf\";"
fp.fact(Write1(BitVecVal(1001,var),BitVecVal(1000,lineNum)))
fp.fact(Heap(BitVecVal(1002,var),BitVecVal(1004,obj)))
fp.fact(Assign(BitVecVal(1001,var),BitVecVal(1005,obj),BitVecVal(1000,lineNum)))
#VariableDecl: var dummyvar;
code[1006]="var dummyvar;"
#VariableDecl: var PROPERTIES = require('./mock-properties').data;
code[1007]="var PROPERTIES = require('./mock-properties').data;"
fp.fact(Write1(BitVecVal(1008,var),BitVecVal(1007,lineNum)))
fp.fact(Read2(BitVecVal(1009,var), BitVecVal(1011,prop), BitVecVal(1007,lineNum)))
fp.fact(Load(BitVecVal(1008,var),BitVecVal(1009,var), BitVecVal(1010,prop),BitVecVal(1007,lineNum)))
#VariableDecl: var favorites = [];
code[1012]="var favorites = [];"
fp.fact(Write1(BitVecVal(1013,var),BitVecVal(1012,lineNum)))
fp.fact(Heap(BitVecVal(1014,var),BitVecVal(1016,obj)))
fp.fact(Assign(BitVecVal(1013,var),BitVecVal(1017,obj),BitVecVal(1012,lineNum)))
#functionDeclaration: findAll
code[1018]="function findAll(req, res, next) {\n//    console.log(1);\n    var tmpv0 = PROPERTIES;\n    res.json(tmpv0);\n}"
fp.fact(FuncDecl(BitVecVal(1019,var),BitVecVal(1020,obj),BitVecVal(1018,lineNum)))
fp.fact(Formal(BitVecVal(1020,obj),BitVecVal(1021,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1020,obj),BitVecVal(1022,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1020,obj),BitVecVal(1023,obj),BitVecVal(3,obj)))
#VariableDecl: var tmpv0 = PROPERTIES;
code[1024]="var tmpv0 = PROPERTIES;"
fp.fact(Write1(BitVecVal(1025,var),BitVecVal(1024,lineNum)))
fp.fact(Read1(BitVecVal(1008,var),BitVecVal(1024,lineNum)))
fp.fact(Assign(BitVecVal(1025,var),BitVecVal(1008,obj),BitVecVal(1024,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:211/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1026]="res.json(tmpv0);"
fp.fact(Actual(BitVecVal(1026,lineNum), BitVecVal(0,num), BitVecVal(1022,var)))
fp.fact(Heap(BitVecVal(1025,var),BitVecVal(1030,obj)))
fp.fact(Actual(BitVecVal(1026,lineNum), BitVecVal(1,num), BitVecVal(1025,var)))
#functionDeclaration: findById
code[1032]="function findById(req, res, next) {\n    var temp4 = req.params;\n    var idd2 = temp4.id;\n    var temp5 = idd2-1;\n    var temp6 = PROPERTIES[temp5];\n    var tmpv1 = temp6;\n    res.json(tmpv1);\n}"
fp.fact(FuncDecl(BitVecVal(1033,var),BitVecVal(1034,obj),BitVecVal(1032,lineNum)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1035,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1036,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1037,obj),BitVecVal(3,obj)))
#VariableDecl: var temp4 = req.params;
code[1038]="var temp4 = req.params;"
fp.fact(Write1(BitVecVal(1039,var),BitVecVal(1038,lineNum)))
fp.fact(Read2(BitVecVal(1035,var), BitVecVal(1041,prop), BitVecVal(1038,lineNum)))
fp.fact(Load(BitVecVal(1039,var),BitVecVal(1035,var), BitVecVal(1040,prop),BitVecVal(1038,lineNum)))
#VariableDecl: var idd2 = temp4.id;
code[1042]="var idd2 = temp4.id;"
fp.fact(Write1(BitVecVal(1043,var),BitVecVal(1042,lineNum)))
fp.fact(Read2(BitVecVal(1039,var), BitVecVal(1045,prop), BitVecVal(1042,lineNum)))
fp.fact(Load(BitVecVal(1043,var),BitVecVal(1039,var), BitVecVal(1044,prop),BitVecVal(1042,lineNum)))
#VariableDecl: var temp5 = idd2-1;
code[1046]="var temp5 = idd2-1;"
fp.fact(Write1(BitVecVal(1047,var),BitVecVal(1046,lineNum)))
fp.fact(Write1(BitVecVal(1047,var),BitVecVal(1046,lineNum)))
fp.fact(Read1(BitVecVal(1043,var),BitVecVal(1046,lineNum)))
fp.fact(Assign(BitVecVal(1047,var),BitVecVal(1043,obj),BitVecVal(1046,lineNum)))
fp.fact(Write1(BitVecVal(1047,var),BitVecVal(1046,lineNum)))
fp.fact(Heap(BitVecVal(1048,var),BitVecVal(1050,obj)))
fp.fact(Assign(BitVecVal(1047,var),BitVecVal(1051,obj),BitVecVal(1046,lineNum)))
#VariableDecl: var temp6 = PROPERTIES[temp5];
code[1052]="var temp6 = PROPERTIES[temp5];"
fp.fact(Write1(BitVecVal(1053,var),BitVecVal(1052,lineNum)))
fp.fact(Read2(BitVecVal(1008,var), BitVecVal(1047,prop), BitVecVal(1052,lineNum)))
fp.fact(Load(BitVecVal(1053,var),BitVecVal(1008,var), BitVecVal(1054,prop),BitVecVal(1052,lineNum)))
#VariableDecl: var tmpv1 = temp6;
code[1055]="var tmpv1 = temp6;"
fp.fact(Write1(BitVecVal(1056,var),BitVecVal(1055,lineNum)))
fp.fact(Read1(BitVecVal(1053,var),BitVecVal(1055,lineNum)))
fp.fact(Assign(BitVecVal(1056,var),BitVecVal(1053,obj),BitVecVal(1055,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:408/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1057]="res.json(tmpv1);"
fp.fact(Actual(BitVecVal(1057,lineNum), BitVecVal(0,num), BitVecVal(1036,var)))
fp.fact(Heap(BitVecVal(1056,var),BitVecVal(1061,obj)))
fp.fact(Actual(BitVecVal(1057,lineNum), BitVecVal(1,num), BitVecVal(1056,var)))
#functionDeclaration: findById
code[1062]="function findById(req, res, next) {\n     var tmpv13 = req.params;\n     var id = tmpv13.id;\n     var tmpv10 = id - 1;\n     var tmpv2 = PROPERTIES[tmpv10];\n     res.json(tmpv2);\n}"
fp.fact(FuncDecl(BitVecVal(1033,var),BitVecVal(1034,obj),BitVecVal(1062,lineNum)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1063,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1064,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1034,obj),BitVecVal(1065,obj),BitVecVal(3,obj)))
#VariableDecl: var tmpv13 = req.params;
code[1066]="var tmpv13 = req.params;"
fp.fact(Write1(BitVecVal(1067,var),BitVecVal(1066,lineNum)))
fp.fact(Read2(BitVecVal(1063,var), BitVecVal(1069,prop), BitVecVal(1066,lineNum)))
fp.fact(Load(BitVecVal(1067,var),BitVecVal(1063,var), BitVecVal(1068,prop),BitVecVal(1066,lineNum)))
#VariableDecl: var id = tmpv13.id;
code[1070]="var id = tmpv13.id;"
fp.fact(Write1(BitVecVal(1071,var),BitVecVal(1070,lineNum)))
fp.fact(Read2(BitVecVal(1067,var), BitVecVal(1073,prop), BitVecVal(1070,lineNum)))
fp.fact(Load(BitVecVal(1071,var),BitVecVal(1067,var), BitVecVal(1072,prop),BitVecVal(1070,lineNum)))
#VariableDecl: var tmpv10 = id - 1;
code[1074]="var tmpv10 = id - 1;"
fp.fact(Write1(BitVecVal(1075,var),BitVecVal(1074,lineNum)))
fp.fact(Write1(BitVecVal(1075,var),BitVecVal(1074,lineNum)))
fp.fact(Read1(BitVecVal(1071,var),BitVecVal(1074,lineNum)))
fp.fact(Assign(BitVecVal(1075,var),BitVecVal(1071,obj),BitVecVal(1074,lineNum)))
fp.fact(Write1(BitVecVal(1075,var),BitVecVal(1074,lineNum)))
fp.fact(Heap(BitVecVal(1076,var),BitVecVal(1078,obj)))
fp.fact(Assign(BitVecVal(1075,var),BitVecVal(1079,obj),BitVecVal(1074,lineNum)))
#VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
code[1080]="var tmpv2 = PROPERTIES[tmpv10];"
fp.fact(Write1(BitVecVal(1081,var),BitVecVal(1080,lineNum)))
fp.fact(Read2(BitVecVal(1008,var), BitVecVal(1075,prop), BitVecVal(1080,lineNum)))
fp.fact(Load(BitVecVal(1081,var),BitVecVal(1008,var), BitVecVal(1082,prop),BitVecVal(1080,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:587/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1083]="res.json(tmpv2);"
fp.fact(Actual(BitVecVal(1083,lineNum), BitVecVal(0,num), BitVecVal(1064,var)))
fp.fact(Heap(BitVecVal(1081,var),BitVecVal(1087,obj)))
fp.fact(Actual(BitVecVal(1083,lineNum), BitVecVal(1,num), BitVecVal(1081,var)))
#functionDeclaration: getFavorites
code[1088]="function getFavorites(req, res, next) {\n    var tmpv3 = favorites;\n    res.json(tmpv3);\n}"
fp.fact(FuncDecl(BitVecVal(1089,var),BitVecVal(1090,obj),BitVecVal(1088,lineNum)))
fp.fact(Formal(BitVecVal(1090,obj),BitVecVal(1091,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1090,obj),BitVecVal(1092,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1090,obj),BitVecVal(1093,obj),BitVecVal(3,obj)))
#VariableDecl: var tmpv3 = favorites;
code[1094]="var tmpv3 = favorites;"
fp.fact(Write1(BitVecVal(1095,var),BitVecVal(1094,lineNum)))
fp.fact(Read1(BitVecVal(1013,var),BitVecVal(1094,lineNum)))
fp.fact(Assign(BitVecVal(1095,var),BitVecVal(1013,obj),BitVecVal(1094,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:680/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1096]="res.json(tmpv3);"
fp.fact(Actual(BitVecVal(1096,lineNum), BitVecVal(0,num), BitVecVal(1092,var)))
fp.fact(Heap(BitVecVal(1095,var),BitVecVal(1100,obj)))
fp.fact(Actual(BitVecVal(1096,lineNum), BitVecVal(1,num), BitVecVal(1095,var)))
#functionDeclaration: favorite
code[1101]="function favorite(req, res, next) {\n    var property = req.body;\n    var exists = false;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }\n    if (!exists) var tmpv4 = property;\n    favorites.push(tmpv4);\n    var tmpv5 = \"success\";\n    res.send(tmpv5)\n}"
fp.fact(FuncDecl(BitVecVal(1102,var),BitVecVal(1103,obj),BitVecVal(1101,lineNum)))
fp.fact(Formal(BitVecVal(1103,obj),BitVecVal(1104,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1103,obj),BitVecVal(1105,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1103,obj),BitVecVal(1106,obj),BitVecVal(3,obj)))
#VariableDecl: var property = req.body;
code[1107]="var property = req.body;"
fp.fact(Write1(BitVecVal(1108,var),BitVecVal(1107,lineNum)))
fp.fact(Read2(BitVecVal(1104,var), BitVecVal(1110,prop), BitVecVal(1107,lineNum)))
fp.fact(Load(BitVecVal(1108,var),BitVecVal(1104,var), BitVecVal(1109,prop),BitVecVal(1107,lineNum)))
#VariableDecl: var exists = false;
code[1111]="var exists = false;"
fp.fact(Write1(BitVecVal(1112,var),BitVecVal(1111,lineNum)))
fp.fact(Heap(BitVecVal(1113,var),BitVecVal(1115,obj)))
fp.fact(Assign(BitVecVal(1112,var),BitVecVal(1116,obj),BitVecVal(1111,lineNum)))
code[1117]="for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }"
fp.fact(controldep(BitVecVal(1118,lineNum),BitVecVal(1117,lineNum)))
fp.fact(controldep(BitVecVal(1119,lineNum),BitVecVal(1117,lineNum)))
fp.fact(controldep(BitVecVal(1120,lineNum),BitVecVal(1117,lineNum)))
#VariableDecl: var i = 0
code[1118]="var i = 0"
fp.fact(Write1(BitVecVal(1121,var),BitVecVal(1118,lineNum)))
fp.fact(Heap(BitVecVal(1122,var),BitVecVal(1124,obj)))
fp.fact(Assign(BitVecVal(1121,var),BitVecVal(1125,obj),BitVecVal(1118,lineNum)))
#BinaryExpression: i < favorites.length
code[1119]="i < favorites.length"
fp.fact(Read1(BitVecVal(1121,var),BitVecVal(1119,lineNum)))
fp.fact(Assign(BitVecVal(0,var),BitVecVal(1121,obj),BitVecVal(1119,lineNum)))
fp.fact(Read2(BitVecVal(1013,var), BitVecVal(1127,prop), BitVecVal(1119,lineNum)))
fp.fact(Load(BitVecVal(0,var),BitVecVal(1013,var), BitVecVal(1126,prop),BitVecVal(1119,lineNum)))
#UpdateExpression: i++
code[1120]="i++"
fp.fact(Write1(BitVecVal(1121,var),BitVecVal(1120,lineNum)))
fp.fact(Read1(BitVecVal(1121,var),BitVecVal(1120,lineNum)))
fp.fact(Assign(BitVecVal(1121,var),BitVecVal(1121,obj),BitVecVal(1120,lineNum)))
code[1128]="if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }"
fp.fact(controldep(BitVecVal(1129,lineNum),BitVecVal(1128,lineNum)))
#BinaryExpression: favorites[i].id === property.id
code[1129]="favorites[i].id === property.id"
fp.fact(Read2(BitVecVal(1013,var), BitVecVal(1121,prop), BitVecVal(1129,lineNum)))
fp.fact(Load(BitVecVal(0,var),BitVecVal(1013,var), BitVecVal(1130,prop),BitVecVal(1129,lineNum)))
fp.fact(Read2(BitVecVal(1108,var), BitVecVal(1132,prop), BitVecVal(1129,lineNum)))
fp.fact(Load(BitVecVal(0,var),BitVecVal(1108,var), BitVecVal(1131,prop),BitVecVal(1129,lineNum)))
#Assignment: exists = true;"
code[1133]="exists = true;"
fp.fact(Write1(BitVecVal(1112,var),BitVecVal(1133,lineNum)))
fp.fact(Heap(BitVecVal(1134,var),BitVecVal(1136,obj)))
fp.fact(Assign(BitVecVal(1112,var),BitVecVal(1137,obj),BitVecVal(1133,lineNum)))
code[1139]="if (!exists) var tmpv4 = property;"
fp.fact(controldep(BitVecVal(1140,lineNum),BitVecVal(1139,lineNum)))
#VariableDecl: var tmpv4 = property;
code[1141]="var tmpv4 = property;"
fp.fact(Write1(BitVecVal(1142,var),BitVecVal(1141,lineNum)))
fp.fact(Read1(BitVecVal(1108,var),BitVecVal(1141,lineNum)))
fp.fact(Assign(BitVecVal(1142,var),BitVecVal(1108,obj),BitVecVal(1141,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:990/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1143]="favorites.push(tmpv4);"
fp.fact(Actual(BitVecVal(1143,lineNum), BitVecVal(0,num), BitVecVal(1013,var)))
fp.fact(Heap(BitVecVal(1142,var),BitVecVal(1147,obj)))
fp.fact(Actual(BitVecVal(1143,lineNum), BitVecVal(1,num), BitVecVal(1142,var)))
#VariableDecl: var tmpv5 = \"success\";
code[1148]="var tmpv5 = \"success\";"
fp.fact(Write1(BitVecVal(1149,var),BitVecVal(1148,lineNum)))
fp.fact(Heap(BitVecVal(1150,var),BitVecVal(1152,obj)))
fp.fact(Assign(BitVecVal(1149,var),BitVecVal(1153,obj),BitVecVal(1148,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:1044/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1154]="res.send(tmpv5)"
fp.fact(Actual(BitVecVal(1154,lineNum), BitVecVal(0,num), BitVecVal(1105,var)))
fp.fact(Heap(BitVecVal(1149,var),BitVecVal(1158,obj)))
fp.fact(Actual(BitVecVal(1154,lineNum), BitVecVal(1,num), BitVecVal(1149,var)))
#functionDeclaration: unfavorite
code[1159]="function unfavorite(req, res, next) {\n    var tmpv14 = req.params;\nvar id = tmpv14.id;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }\n    var tmpv8 = favorites;\nres.json(tmpv8)\n}"
fp.fact(FuncDecl(BitVecVal(1160,var),BitVecVal(1161,obj),BitVecVal(1159,lineNum)))
fp.fact(Formal(BitVecVal(1161,obj),BitVecVal(1162,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1161,obj),BitVecVal(1163,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1161,obj),BitVecVal(1164,obj),BitVecVal(3,obj)))
#VariableDecl: var tmpv14 = req.params;
code[1165]="var tmpv14 = req.params;"
fp.fact(Write1(BitVecVal(1166,var),BitVecVal(1165,lineNum)))
fp.fact(Read2(BitVecVal(1162,var), BitVecVal(1168,prop), BitVecVal(1165,lineNum)))
fp.fact(Load(BitVecVal(1166,var),BitVecVal(1162,var), BitVecVal(1167,prop),BitVecVal(1165,lineNum)))
#VariableDecl: var id = tmpv14.id;
code[1169]="var id = tmpv14.id;"
fp.fact(Write1(BitVecVal(1170,var),BitVecVal(1169,lineNum)))
fp.fact(Read2(BitVecVal(1166,var), BitVecVal(1172,prop), BitVecVal(1169,lineNum)))
fp.fact(Load(BitVecVal(1170,var),BitVecVal(1166,var), BitVecVal(1171,prop),BitVecVal(1169,lineNum)))
code[1173]="for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }"
fp.fact(controldep(BitVecVal(1174,lineNum),BitVecVal(1173,lineNum)))
fp.fact(controldep(BitVecVal(1175,lineNum),BitVecVal(1173,lineNum)))
fp.fact(controldep(BitVecVal(1176,lineNum),BitVecVal(1173,lineNum)))
#VariableDecl: var i = 0
code[1174]="var i = 0"
fp.fact(Write1(BitVecVal(1177,var),BitVecVal(1174,lineNum)))
fp.fact(Heap(BitVecVal(1178,var),BitVecVal(1180,obj)))
fp.fact(Assign(BitVecVal(1177,var),BitVecVal(1181,obj),BitVecVal(1174,lineNum)))
#BinaryExpression: i < favorites.length
code[1175]="i < favorites.length"
fp.fact(Read1(BitVecVal(1177,var),BitVecVal(1175,lineNum)))
fp.fact(Assign(BitVecVal(0,var),BitVecVal(1177,obj),BitVecVal(1175,lineNum)))
fp.fact(Read2(BitVecVal(1013,var), BitVecVal(1183,prop), BitVecVal(1175,lineNum)))
fp.fact(Load(BitVecVal(0,var),BitVecVal(1013,var), BitVecVal(1182,prop),BitVecVal(1175,lineNum)))
#UpdateExpression: i++
code[1176]="i++"
fp.fact(Write1(BitVecVal(1177,var),BitVecVal(1176,lineNum)))
fp.fact(Read1(BitVecVal(1177,var),BitVecVal(1176,lineNum)))
fp.fact(Assign(BitVecVal(1177,var),BitVecVal(1177,obj),BitVecVal(1176,lineNum)))
code[1184]="if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }"
fp.fact(controldep(BitVecVal(1185,lineNum),BitVecVal(1184,lineNum)))
#BinaryExpression: favorites[i].id == id
code[1185]="favorites[i].id == id"
fp.fact(Read2(BitVecVal(1013,var), BitVecVal(1177,prop), BitVecVal(1185,lineNum)))
fp.fact(Load(BitVecVal(0,var),BitVecVal(1013,var), BitVecVal(1186,prop),BitVecVal(1185,lineNum)))
fp.fact(Read1(BitVecVal(1170,var),BitVecVal(1185,lineNum)))
fp.fact(Assign(BitVecVal(0,var),BitVecVal(1170,obj),BitVecVal(1185,lineNum)))
#VariableDecl: var tmpv6 = i;
code[1187]="var tmpv6 = i;"
fp.fact(Write1(BitVecVal(1188,var),BitVecVal(1187,lineNum)))
fp.fact(Read1(BitVecVal(1177,var),BitVecVal(1187,lineNum)))
fp.fact(Assign(BitVecVal(1188,var),BitVecVal(1177,obj),BitVecVal(1187,lineNum)))
#VariableDecl: var tmpv7 = 1;
code[1189]="var tmpv7 = 1;"
fp.fact(Write1(BitVecVal(1190,var),BitVecVal(1189,lineNum)))
fp.fact(Heap(BitVecVal(1191,var),BitVecVal(1193,obj)))
fp.fact(Assign(BitVecVal(1190,var),BitVecVal(1194,obj),BitVecVal(1189,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:1279/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1195]="favorites.splice(tmpv6, tmpv7);"
fp.fact(Actual(BitVecVal(1195,lineNum), BitVecVal(0,num), BitVecVal(1013,var)))
fp.fact(Heap(BitVecVal(1188,var),BitVecVal(1199,obj)))
fp.fact(Actual(BitVecVal(1195,lineNum), BitVecVal(1,num), BitVecVal(1188,var)))
fp.fact(Heap(BitVecVal(1190,var),BitVecVal(1203,obj)))
fp.fact(Actual(BitVecVal(1195,lineNum), BitVecVal(2,num), BitVecVal(1190,var)))
#VariableDecl: var tmpv8 = favorites;
code[1205]="var tmpv8 = favorites;"
fp.fact(Write1(BitVecVal(1206,var),BitVecVal(1205,lineNum)))
fp.fact(Read1(BitVecVal(1013,var),BitVecVal(1205,lineNum)))
fp.fact(Assign(BitVecVal(1206,var),BitVecVal(1013,obj),BitVecVal(1205,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:1373/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1207]="res.json(tmpv8)"
fp.fact(Actual(BitVecVal(1207,lineNum), BitVecVal(0,num), BitVecVal(1163,var)))
fp.fact(Heap(BitVecVal(1206,var),BitVecVal(1211,obj)))
fp.fact(Actual(BitVecVal(1207,lineNum), BitVecVal(1,num), BitVecVal(1206,var)))
#functionDeclaration: like
code[1212]="function like(req, res, next) {\n    var property = req.body;\n    var tmpv11 = property.id - 1;\nPROPERTIES[tmpv11].likes++;\n    var tmpv12 = property.id - 1;\nvar tmpv9 = PROPERTIES[tmpv12].likes;\nres.json(tmpv9);\n}"
fp.fact(FuncDecl(BitVecVal(1213,var),BitVecVal(1214,obj),BitVecVal(1212,lineNum)))
fp.fact(Formal(BitVecVal(1214,obj),BitVecVal(1215,obj),BitVecVal(1,obj)))
fp.fact(Formal(BitVecVal(1214,obj),BitVecVal(1216,obj),BitVecVal(2,obj)))
fp.fact(Formal(BitVecVal(1214,obj),BitVecVal(1217,obj),BitVecVal(3,obj)))
#VariableDecl: var property = req.body;
code[1218]="var property = req.body;"
fp.fact(Write1(BitVecVal(1219,var),BitVecVal(1218,lineNum)))
fp.fact(Read2(BitVecVal(1215,var), BitVecVal(1221,prop), BitVecVal(1218,lineNum)))
fp.fact(Load(BitVecVal(1219,var),BitVecVal(1215,var), BitVecVal(1220,prop),BitVecVal(1218,lineNum)))
#VariableDecl: var tmpv11 = property.id - 1;
code[1222]="var tmpv11 = property.id - 1;"
fp.fact(Write1(BitVecVal(1223,var),BitVecVal(1222,lineNum)))
fp.fact(Write1(BitVecVal(1223,var),BitVecVal(1222,lineNum)))
fp.fact(Read2(BitVecVal(1219,var), BitVecVal(1225,prop), BitVecVal(1222,lineNum)))
fp.fact(Load(BitVecVal(1223,var),BitVecVal(1219,var), BitVecVal(1224,prop),BitVecVal(1222,lineNum)))
fp.fact(Write1(BitVecVal(1223,var),BitVecVal(1222,lineNum)))
fp.fact(Heap(BitVecVal(1226,var),BitVecVal(1228,obj)))
fp.fact(Assign(BitVecVal(1223,var),BitVecVal(1229,obj),BitVecVal(1222,lineNum)))
#UpdateExpression: PROPERTIES[tmpv11].likes++;
code[1230]="PROPERTIES[tmpv11].likes++;"
fp.fact(Write2(BitVecVal(1008,obj),BitVecVal(1223,var), BitVecVal(1230,lineNum)))
fp.fact(Read2(BitVecVal(1008,var), BitVecVal(1223,prop), BitVecVal(1230,lineNum)))
fp.fact(Load(BitVecVal(1232,var),BitVecVal(1231,prop), BitVecVal(1231,var),BitVecVal(1230,lineNum)))
fp.fact(Store(BitVecVal(1082,var),BitVecVal(1008,prop), BitVecVal(1231,var), BitVecVal(1230,lineNum)))
#VariableDecl: var tmpv12 = property.id - 1;
code[1233]="var tmpv12 = property.id - 1;"
fp.fact(Write1(BitVecVal(1234,var),BitVecVal(1233,lineNum)))
fp.fact(Write1(BitVecVal(1234,var),BitVecVal(1233,lineNum)))
fp.fact(Read2(BitVecVal(1219,var), BitVecVal(1236,prop), BitVecVal(1233,lineNum)))
fp.fact(Load(BitVecVal(1234,var),BitVecVal(1219,var), BitVecVal(1235,prop),BitVecVal(1233,lineNum)))
fp.fact(Write1(BitVecVal(1234,var),BitVecVal(1233,lineNum)))
fp.fact(Heap(BitVecVal(1237,var),BitVecVal(1239,obj)))
fp.fact(Assign(BitVecVal(1234,var),BitVecVal(1240,obj),BitVecVal(1233,lineNum)))
#VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
code[1241]="var tmpv9 = PROPERTIES[tmpv12].likes;"
fp.fact(Write1(BitVecVal(1242,var),BitVecVal(1241,lineNum)))
fp.fact(Read2(BitVecVal(1008,var), BitVecVal(1234,prop), BitVecVal(1241,lineNum)))
fp.fact(Load(BitVecVal(1242,var),BitVecVal(1008,var), BitVecVal(1243,prop),BitVecVal(1241,lineNum)))
#CallExpression:subject_apps/ionic2-realty-rest/server/norm_property-service.js:1587/Users/kijin/projects/public/public_artifact/tmp/JS-RCI
code[1244]="res.json(tmpv9);"
fp.fact(Actual(BitVecVal(1244,lineNum), BitVecVal(0,num), BitVecVal(1216,var)))
fp.fact(Heap(BitVecVal(1242,var),BitVecVal(1248,obj)))
fp.fact(Actual(BitVecVal(1244,lineNum), BitVecVal(1,num), BitVecVal(1242,var)))
#Assignment: exports.findAll = findAll;"
code[1249]="exports.findAll = findAll;"
fp.fact(Write2(BitVecVal(1250,obj),BitVecVal(1251,var), BitVecVal(1249,lineNum)))
fp.fact(Read1(BitVecVal(1252,var),BitVecVal(1249,lineNum)))
fp.fact(Store(BitVecVal(3567,var),BitVecVal(1020,var), BitVecVal(1252,prop), BitVecVal(1249,lineNum)))
#Assignment: exports.findById = findById;"
code[1253]="exports.findById = findById;"
fp.fact(Write2(BitVecVal(1254,obj),BitVecVal(1255,var), BitVecVal(1253,lineNum)))
fp.fact(Read1(BitVecVal(1256,var),BitVecVal(1253,lineNum)))
fp.fact(Store(BitVecVal(1250,var),BitVecVal(1034,var), BitVecVal(1256,prop), BitVecVal(1253,lineNum)))
#Assignment: exports.getFavorites = getFavorites;"
code[1257]="exports.getFavorites = getFavorites;"
fp.fact(Write2(BitVecVal(1258,obj),BitVecVal(1259,var), BitVecVal(1257,lineNum)))
fp.fact(Read1(BitVecVal(1260,var),BitVecVal(1257,lineNum)))
fp.fact(Store(BitVecVal(1254,var),BitVecVal(1090,var), BitVecVal(1260,prop), BitVecVal(1257,lineNum)))
#Assignment: exports.favorite = favorite;"
code[1261]="exports.favorite = favorite;"
fp.fact(Write2(BitVecVal(1262,obj),BitVecVal(1263,var), BitVecVal(1261,lineNum)))
fp.fact(Read1(BitVecVal(1264,var),BitVecVal(1261,lineNum)))
fp.fact(Store(BitVecVal(1258,var),BitVecVal(1103,var), BitVecVal(1264,prop), BitVecVal(1261,lineNum)))
#Assignment: exports.unfavorite = unfavorite;"
code[1265]="exports.unfavorite = unfavorite;"
fp.fact(Write2(BitVecVal(1266,obj),BitVecVal(1267,var), BitVecVal(1265,lineNum)))
fp.fact(Read1(BitVecVal(1268,var),BitVecVal(1265,lineNum)))
fp.fact(Store(BitVecVal(1262,var),BitVecVal(1161,var), BitVecVal(1268,prop), BitVecVal(1265,lineNum)))
#Assignment: exports.like = like;"
code[1269]="exports.like = like;"
fp.fact(Write2(BitVecVal(1270,obj),BitVecVal(1271,var), BitVecVal(1269,lineNum)))
fp.fact(Read1(BitVecVal(1272,var),BitVecVal(1269,lineNum)))
fp.fact(Store(BitVecVal(1266,var),BitVecVal(1214,var), BitVecVal(1272,prop), BitVecVal(1269,lineNum)))









fp.fact(controldep(BitVecVal(1024,lineNum),BitVecVal(1026,lineNum)))



fp.fact(controldep(BitVecVal(1038,lineNum),BitVecVal(1042,lineNum)))

fp.fact(controldep(BitVecVal(1042,lineNum),BitVecVal(1046,lineNum)))

fp.fact(controldep(BitVecVal(1046,lineNum),BitVecVal(1052,lineNum)))

fp.fact(controldep(BitVecVal(1052,lineNum),BitVecVal(1055,lineNum)))

fp.fact(controldep(BitVecVal(1055,lineNum),BitVecVal(1057,lineNum)))



fp.fact(controldep(BitVecVal(1066,lineNum),BitVecVal(1070,lineNum)))

fp.fact(controldep(BitVecVal(1070,lineNum),BitVecVal(1074,lineNum)))

fp.fact(controldep(BitVecVal(1074,lineNum),BitVecVal(1080,lineNum)))

fp.fact(controldep(BitVecVal(1080,lineNum),BitVecVal(1083,lineNum)))



fp.fact(controldep(BitVecVal(1094,lineNum),BitVecVal(1096,lineNum)))



fp.fact(controldep(BitVecVal(1107,lineNum),BitVecVal(1111,lineNum)))



fp.fact(controldep(BitVecVal(1117,lineNum),BitVecVal(1128,lineNum)))

fp.fact(controldep(BitVecVal(1128,lineNum),BitVecVal(1133,lineNum)))

fp.fact(controldep(BitVecVal(1117,lineNum),BitVecVal(1139,lineNum)))

fp.fact(controldep(BitVecVal(1139,lineNum),BitVecVal(1141,lineNum)))

fp.fact(controldep(BitVecVal(1139,lineNum),BitVecVal(1143,lineNum)))

fp.fact(controldep(BitVecVal(1143,lineNum),BitVecVal(1148,lineNum)))

fp.fact(controldep(BitVecVal(1148,lineNum),BitVecVal(1154,lineNum)))



fp.fact(controldep(BitVecVal(1165,lineNum),BitVecVal(1169,lineNum)))



fp.fact(controldep(BitVecVal(1173,lineNum),BitVecVal(1184,lineNum)))

fp.fact(controldep(BitVecVal(1184,lineNum),BitVecVal(1187,lineNum)))

fp.fact(controldep(BitVecVal(1187,lineNum),BitVecVal(1189,lineNum)))

fp.fact(controldep(BitVecVal(1189,lineNum),BitVecVal(1195,lineNum)))

fp.fact(controldep(BitVecVal(1173,lineNum),BitVecVal(1205,lineNum)))

fp.fact(controldep(BitVecVal(1205,lineNum),BitVecVal(1207,lineNum)))



fp.fact(controldep(BitVecVal(1218,lineNum),BitVecVal(1222,lineNum)))

fp.fact(controldep(BitVecVal(1222,lineNum),BitVecVal(1230,lineNum)))

fp.fact(controldep(BitVecVal(1230,lineNum),BitVecVal(1233,lineNum)))

fp.fact(controldep(BitVecVal(1233,lineNum),BitVecVal(1241,lineNum)))

fp.fact(controldep(BitVecVal(1241,lineNum),BitVecVal(1244,lineNum)))







hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:9:34"]={"bin":1000, "name":"var dummyvar1=\"sfasfasf\";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:13:22"]={"bin":1001, "name":"dummyvar1"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:35:48"]={"bin":1006, "name":"var dummyvar;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:49:100"]={"bin":1007, "name":"var PROPERTIES = require('./mock-properties').data;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:53:63"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:66:94"]={"bin":1009, "name":"require('./mock-properties')"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:66:99"]={"bin":1010, "name":"require('./mock-properties').data"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:95:99"]={"bin":1011, "name":"data"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:101:120"]={"bin":1012, "name":"var favorites = [];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:105:114"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:122:229"]={"bin":1018, "name":"function findAll(req, res, next) {\n//    console.log(1);\n    var tmpv0 = PROPERTIES;\n    res.json(tmpv0);\n}"};
hashVar["O_findAll"]={"bin":1019, "name":"O_findAll"};
hashVar["findAll"]={"bin":1020, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:139:142"]={"bin":1021, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:144:147"]={"bin":1022, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:149:153"]={"bin":1023, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:183:206"]={"bin":1024, "name":"var tmpv0 = PROPERTIES;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:187:192"]={"bin":1025, "name":"tmpv0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:195:205"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:211:227"]={"bin":1026, "name":"res.json(tmpv0);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:211:214"]={"bin":1022, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:220:225"]={"bin":1025, "name":"tmpv0"};
hashVar["2tempHash"]={"bin":1030, "name":"2tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:229:230"]={"bin":1031, "name":";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:233:426"]={"bin":1032, "name":"function findById(req, res, next) {\n    var temp4 = req.params;\n    var idd2 = temp4.id;\n    var temp5 = idd2-1;\n    var temp6 = PROPERTIES[temp5];\n    var tmpv1 = temp6;\n    res.json(tmpv1);\n}"};
hashVar["O_findById"]={"bin":1033, "name":"O_findById"};
hashVar["findById"]={"bin":1034, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:251:254"]={"bin":1035, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:256:259"]={"bin":1036, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:261:265"]={"bin":1037, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:273:296"]={"bin":1038, "name":"var temp4 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:277:282"]={"bin":1039, "name":"temp4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:285:288"]={"bin":1035, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:285:295"]={"bin":1040, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:289:295"]={"bin":1041, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:301:321"]={"bin":1042, "name":"var idd2 = temp4.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:305:309"]={"bin":1043, "name":"idd2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:312:317"]={"bin":1039, "name":"temp4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:312:320"]={"bin":1044, "name":"temp4.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:318:320"]={"bin":1045, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:326:345"]={"bin":1046, "name":"var temp5 = idd2-1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:330:335"]={"bin":1047, "name":"temp5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:338:342"]={"bin":1043, "name":"idd2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:350:380"]={"bin":1052, "name":"var temp6 = PROPERTIES[temp5];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:354:359"]={"bin":1053, "name":"temp6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:362:372"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:362:379"]={"bin":1054, "name":"PROPERTIES[temp5]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:373:378"]={"bin":1047, "name":"temp5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:385:403"]={"bin":1055, "name":"var tmpv1 = temp6;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:389:394"]={"bin":1056, "name":"tmpv1"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:397:402"]={"bin":1053, "name":"temp6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:408:424"]={"bin":1057, "name":"res.json(tmpv1);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:408:411"]={"bin":1036, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:417:422"]={"bin":1056, "name":"tmpv1"};
hashVar["4tempHash"]={"bin":1061, "name":"4tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:428:605"]={"bin":1062, "name":"function findById(req, res, next) {\n     var tmpv13 = req.params;\n     var id = tmpv13.id;\n     var tmpv10 = id - 1;\n     var tmpv2 = PROPERTIES[tmpv10];\n     res.json(tmpv2);\n}"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:446:449"]={"bin":1063, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:451:454"]={"bin":1064, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:456:460"]={"bin":1065, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:469:493"]={"bin":1066, "name":"var tmpv13 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:473:479"]={"bin":1067, "name":"tmpv13"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:482:485"]={"bin":1063, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:482:492"]={"bin":1068, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:486:492"]={"bin":1069, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:499:518"]={"bin":1070, "name":"var id = tmpv13.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:503:505"]={"bin":1071, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:508:514"]={"bin":1067, "name":"tmpv13"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:508:517"]={"bin":1072, "name":"tmpv13.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:515:517"]={"bin":1073, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:524:544"]={"bin":1074, "name":"var tmpv10 = id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:528:534"]={"bin":1075, "name":"tmpv10"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:537:539"]={"bin":1071, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:550:581"]={"bin":1080, "name":"var tmpv2 = PROPERTIES[tmpv10];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:554:559"]={"bin":1081, "name":"tmpv2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:562:572"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:562:580"]={"bin":1082, "name":"PROPERTIES[tmpv10]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:573:579"]={"bin":1075, "name":"tmpv10"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:587:603"]={"bin":1083, "name":"res.json(tmpv2);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:587:590"]={"bin":1064, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:596:601"]={"bin":1081, "name":"tmpv2"};
hashVar["6tempHash"]={"bin":1087, "name":"6tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:609:698"]={"bin":1088, "name":"function getFavorites(req, res, next) {\n    var tmpv3 = favorites;\n    res.json(tmpv3);\n}"};
hashVar["O_getFavorites"]={"bin":1089, "name":"O_getFavorites"};
hashVar["getFavorites"]={"bin":1090, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:631:634"]={"bin":1091, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:636:639"]={"bin":1092, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:641:645"]={"bin":1093, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:653:675"]={"bin":1094, "name":"var tmpv3 = favorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:657:662"]={"bin":1095, "name":"tmpv3"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:665:674"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:680:696"]={"bin":1096, "name":"res.json(tmpv3);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:680:683"]={"bin":1092, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:689:694"]={"bin":1095, "name":"tmpv3"};
hashVar["7tempHash"]={"bin":1100, "name":"7tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:700:1061"]={"bin":1101, "name":"function favorite(req, res, next) {\n    var property = req.body;\n    var exists = false;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }\n    if (!exists) var tmpv4 = property;\n    favorites.push(tmpv4);\n    var tmpv5 = \"success\";\n    res.send(tmpv5)\n}"};
hashVar["O_favorite"]={"bin":1102, "name":"O_favorite"};
hashVar["favorite"]={"bin":1103, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:718:721"]={"bin":1104, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:723:726"]={"bin":1105, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:728:732"]={"bin":1106, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:740:764"]={"bin":1107, "name":"var property = req.body;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:744:752"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:755:758"]={"bin":1104, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:755:763"]={"bin":1109, "name":"req.body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:759:763"]={"bin":1110, "name":"body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:769:788"]={"bin":1111, "name":"var exists = false;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:773:779"]={"bin":1112, "name":"exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:793:946"]={"bin":1117, "name":"for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:798:807"]={"bin":1118, "name":"var i = 0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:809:829"]={"bin":1119, "name":"i < favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:831:834"]={"bin":1120, "name":"i++"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:802:803"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:809:810"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:813:822"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:813:829"]={"bin":1126, "name":"favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:823:829"]={"bin":1127, "name":"length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:831:832"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:846:940"]={"bin":1128, "name":"if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:881"]={"bin":1129, "name":"favorites[i].id === property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:859"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:862"]={"bin":1130, "name":"favorites[i]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:860:861"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:870:878"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:870:881"]={"bin":1131, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:879:881"]={"bin":1132, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:897:911"]={"bin":1133, "name":"exists = true;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:897:903"]={"bin":1112, "name":"exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:924:930"]={"bin":1138, "name":"break;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:951:985"]={"bin":1139, "name":"if (!exists) var tmpv4 = property;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:955:962"]={"bin":1140, "name":"!exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:964:985"]={"bin":1141, "name":"var tmpv4 = property;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:968:973"]={"bin":1142, "name":"tmpv4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:976:984"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:990:1012"]={"bin":1143, "name":"favorites.push(tmpv4);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:990:999"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1005:1010"]={"bin":1142, "name":"tmpv4"};
hashVar["11tempHash"]={"bin":1147, "name":"11tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1017:1039"]={"bin":1148, "name":"var tmpv5 = \"success\";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1021:1026"]={"bin":1149, "name":"tmpv5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1044:1059"]={"bin":1154, "name":"res.send(tmpv5)"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1044:1047"]={"bin":1105, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1053:1058"]={"bin":1149, "name":"tmpv5"};
hashVar["13tempHash"]={"bin":1158, "name":"13tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1063:1390"]={"bin":1159, "name":"function unfavorite(req, res, next) {\n    var tmpv14 = req.params;\nvar id = tmpv14.id;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }\n    var tmpv8 = favorites;\nres.json(tmpv8)\n}"};
hashVar["O_unfavorite"]={"bin":1160, "name":"O_unfavorite"};
hashVar["unfavorite"]={"bin":1161, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1083:1086"]={"bin":1162, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1088:1091"]={"bin":1163, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1093:1097"]={"bin":1164, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1105:1129"]={"bin":1165, "name":"var tmpv14 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1109:1115"]={"bin":1166, "name":"tmpv14"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1118:1121"]={"bin":1162, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1118:1128"]={"bin":1167, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1122:1128"]={"bin":1168, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1130:1149"]={"bin":1169, "name":"var id = tmpv14.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1134:1136"]={"bin":1170, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1139:1145"]={"bin":1166, "name":"tmpv14"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1139:1148"]={"bin":1171, "name":"tmpv14.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1146:1148"]={"bin":1172, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1154:1345"]={"bin":1173, "name":"for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1159:1168"]={"bin":1174, "name":"var i = 0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1170:1190"]={"bin":1175, "name":"i < favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1192:1195"]={"bin":1176, "name":"i++"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1163:1164"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1170:1171"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1174:1183"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1174:1190"]={"bin":1182, "name":"favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1184:1190"]={"bin":1183, "name":"length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1192:1193"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1207:1339"]={"bin":1184, "name":"if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1232"]={"bin":1185, "name":"favorites[i].id == id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1220"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1223"]={"bin":1186, "name":"favorites[i]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1221:1222"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1230:1232"]={"bin":1170, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1248:1262"]={"bin":1187, "name":"var tmpv6 = i;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1252:1257"]={"bin":1188, "name":"tmpv6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1260:1261"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1264:1278"]={"bin":1189, "name":"var tmpv7 = 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1268:1273"]={"bin":1190, "name":"tmpv7"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1279:1310"]={"bin":1195, "name":"favorites.splice(tmpv6, tmpv7);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1279:1288"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1296:1301"]={"bin":1188, "name":"tmpv6"};
hashVar["16tempHash"]={"bin":1199, "name":"16tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1303:1308"]={"bin":1190, "name":"tmpv7"};
hashVar["17tempHash"]={"bin":1203, "name":"17tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1323:1329"]={"bin":1204, "name":"break;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1350:1372"]={"bin":1205, "name":"var tmpv8 = favorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1354:1359"]={"bin":1206, "name":"tmpv8"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1362:1371"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1373:1388"]={"bin":1207, "name":"res.json(tmpv8)"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1373:1376"]={"bin":1163, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1382:1387"]={"bin":1206, "name":"tmpv8"};
hashVar["18tempHash"]={"bin":1211, "name":"18tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1392:1605"]={"bin":1212, "name":"function like(req, res, next) {\n    var property = req.body;\n    var tmpv11 = property.id - 1;\nPROPERTIES[tmpv11].likes++;\n    var tmpv12 = property.id - 1;\nvar tmpv9 = PROPERTIES[tmpv12].likes;\nres.json(tmpv9);\n}"};
hashVar["O_like"]={"bin":1213, "name":"O_like"};
hashVar["like"]={"bin":1214, "name":"like"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1406:1409"]={"bin":1215, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1411:1414"]={"bin":1216, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1416:1420"]={"bin":1217, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1428:1452"]={"bin":1218, "name":"var property = req.body;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1432:1440"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1443:1446"]={"bin":1215, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1443:1451"]={"bin":1220, "name":"req.body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1447:1451"]={"bin":1221, "name":"body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1457:1486"]={"bin":1222, "name":"var tmpv11 = property.id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1461:1467"]={"bin":1223, "name":"tmpv11"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1470:1478"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1470:1481"]={"bin":1224, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1479:1481"]={"bin":1225, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1514"]={"bin":1230, "name":"PROPERTIES[tmpv11].likes++;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1497"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1498:1504"]={"bin":1223, "name":"tmpv11"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1505"]={"bin":1231, "name":"PROPERTIES[tmpv11]"};
hashVar["ttemp0"]={"bin":1232, "name":"ttemp0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1519:1548"]={"bin":1233, "name":"var tmpv12 = property.id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1523:1529"]={"bin":1234, "name":"tmpv12"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1532:1540"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1532:1543"]={"bin":1235, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1541:1543"]={"bin":1236, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1549:1586"]={"bin":1241, "name":"var tmpv9 = PROPERTIES[tmpv12].likes;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1553:1558"]={"bin":1242, "name":"tmpv9"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1561:1571"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1561:1579"]={"bin":1243, "name":"PROPERTIES[tmpv12]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1572:1578"]={"bin":1234, "name":"tmpv12"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1587:1603"]={"bin":1244, "name":"res.json(tmpv9);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1587:1590"]={"bin":1216, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1596:1601"]={"bin":1242, "name":"tmpv9"};
hashVar["21tempHash"]={"bin":1248, "name":"21tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1607:1633"]={"bin":1249, "name":"exports.findAll = findAll;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1607:1614"]={"bin":1250, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1615:1622"]={"bin":1251, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1625:1632"]={"bin":1252, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1634:1662"]={"bin":1253, "name":"exports.findById = findById;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1634:1641"]={"bin":1254, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1642:1650"]={"bin":1255, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1653:1661"]={"bin":1256, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1663:1699"]={"bin":1257, "name":"exports.getFavorites = getFavorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1663:1670"]={"bin":1258, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1671:1683"]={"bin":1259, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1686:1698"]={"bin":1260, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1700:1728"]={"bin":1261, "name":"exports.favorite = favorite;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1700:1707"]={"bin":1262, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1708:1716"]={"bin":1263, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1719:1727"]={"bin":1264, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1729:1761"]={"bin":1265, "name":"exports.unfavorite = unfavorite;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1729:1736"]={"bin":1266, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1737:1747"]={"bin":1267, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1750:1760"]={"bin":1268, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1762:1782"]={"bin":1269, "name":"exports.like = like;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1762:1769"]={"bin":1270, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1770:1774"]={"bin":1271, "name":"like"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1777:1781"]={"bin":1272, "name":"like"};
#Assignment: exports.data = [\n        {\n            id: 1,\n            city: 'Boston',\n            state: 'MA',\n            price: '$475,000',\n            title: 'Condominium Redefined',\n            beds: 2,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 2,\n            city: 'Cambridge',\n            state: 'MA',\n            price: '$1,200,000',\n            title: 'Ultimate Sophistication',\n            beds: 5,\n            baths: 4,\n            likes: 2,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 3,\n            city: 'Boston',\n            state: 'MA',\n            price: '$650,000',\n            title: 'Seaport District Retreat',\n            beds: 3,\n            baths: 2,\n            likes: 6,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 4,\n            city: 'Boston',\n            state: 'MA',\n            price: '$875,000',\n            title: 'Modern City Living',\n            beds: 3,\n            baths: 2,\n            likes: 12,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 5,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$425,000',\n            title: 'Urban Efficiency',\n            beds: 4,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 6,\n            city: 'Boston',\n            state: 'MA',\n            price: '$550,000',\n            title: 'Waterfront in the City',\n            beds: 3,\n            baths: 2,\n            likes: 14,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 7,\n            city: 'Brookline',\n            state: 'MA',\n            zip: '02420',\n            price: '$850,000',\n            title: 'Suburban Extravaganza',\n            beds: 5,\n            baths: 4,\n            likes: 5,\n            broker: {\n                id: 7,\n                name: \"Michelle Lambert\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michelle_lambert.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 8,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$925,000',\n            title: 'Contemporary Luxury',\n            beds: 6,\n            baths: 6,\n            sqft: 950,\n            likes: 8,\n            broker: {\n                id: 8,\n                name: \"Victor Oachoa\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/victor_ochoa.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 9,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$550,000',\n            title: 'Heart of Harvard Square',\n            beds: 5,\n            baths: 4,\n            likes: 9,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 10,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$375,000',\n            title: 'Architectural Details',\n            beds: 2,\n            baths: 2,\n            likes: 10,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 11,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$495,000',\n            title: 'Modern Elegance',\n            beds: 2,\n            baths: 2,\n            likes: 16,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 12,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$625,000',\n            title: 'Stunning Colonial',\n            beds: 4,\n            baths: 2,\n            likes: 9,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 13,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$430,000',\n            title: 'Quiet Retreat',\n            beds: 5,\n            baths:4,\n            likes: 18,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 14,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '01742',\n            price: '$450,000',\n            title: 'Victorian Revival',\n            beds: 4,\n            baths:3,\n            sqft: 3800,\n            likes: 10,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        }\n    ];"
code[1273]="exports.data = [\n        {\n            id: 1,\n            city: 'Boston',\n            state: 'MA',\n            price: '$475,000',\n            title: 'Condominium Redefined',\n            beds: 2,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 2,\n            city: 'Cambridge',\n            state: 'MA',\n            price: '$1,200,000',\n            title: 'Ultimate Sophistication',\n            beds: 5,\n            baths: 4,\n            likes: 2,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 3,\n            city: 'Boston',\n            state: 'MA',\n            price: '$650,000',\n            title: 'Seaport District Retreat',\n            beds: 3,\n            baths: 2,\n            likes: 6,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 4,\n            city: 'Boston',\n            state: 'MA',\n            price: '$875,000',\n            title: 'Modern City Living',\n            beds: 3,\n            baths: 2,\n            likes: 12,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 5,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$425,000',\n            title: 'Urban Efficiency',\n            beds: 4,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 6,\n            city: 'Boston',\n            state: 'MA',\n            price: '$550,000',\n            title: 'Waterfront in the City',\n            beds: 3,\n            baths: 2,\n            likes: 14,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 7,\n            city: 'Brookline',\n            state: 'MA',\n            zip: '02420',\n            price: '$850,000',\n            title: 'Suburban Extravaganza',\n            beds: 5,\n            baths: 4,\n            likes: 5,\n            broker: {\n                id: 7,\n                name: \"Michelle Lambert\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michelle_lambert.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 8,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$925,000',\n            title: 'Contemporary Luxury',\n            beds: 6,\n            baths: 6,\n            sqft: 950,\n            likes: 8,\n            broker: {\n                id: 8,\n                name: \"Victor Oachoa\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/victor_ochoa.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 9,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$550,000',\n            title: 'Heart of Harvard Square',\n            beds: 5,\n            baths: 4,\n            likes: 9,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 10,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$375,000',\n            title: 'Architectural Details',\n            beds: 2,\n            baths: 2,\n            likes: 10,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 11,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$495,000',\n            title: 'Modern Elegance',\n            beds: 2,\n            baths: 2,\n            likes: 16,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 12,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$625,000',\n            title: 'Stunning Colonial',\n            beds: 4,\n            baths: 2,\n            likes: 9,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 13,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$430,000',\n            title: 'Quiet Retreat',\n            beds: 5,\n            baths:4,\n            likes: 18,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 14,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '01742',\n            price: '$450,000',\n            title: 'Victorian Revival',\n            beds: 4,\n            baths:3,\n            sqft: 3800,\n            likes: 10,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        }\n    ];"
fp.fact(Write2(BitVecVal(1274,obj),BitVecVal(1275,var), BitVecVal(1273,lineNum)))
fp.fact(Heap(BitVecVal(1276,var),BitVecVal(1278,obj)))
fp.fact(Store(BitVecVal(1270,var),BitVecVal(1011,var), BitVecVal(1279,prop), BitVecVal(1273,lineNum)))




hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:9:34"]={"bin":1000, "name":"var dummyvar1=\"sfasfasf\";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:13:22"]={"bin":1001, "name":"dummyvar1"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:35:48"]={"bin":1006, "name":"var dummyvar;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:49:100"]={"bin":1007, "name":"var PROPERTIES = require('./mock-properties').data;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:53:63"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:66:94"]={"bin":1009, "name":"require('./mock-properties')"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:66:99"]={"bin":1010, "name":"require('./mock-properties').data"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:95:99"]={"bin":1011, "name":"data"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:101:120"]={"bin":1012, "name":"var favorites = [];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:105:114"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:122:229"]={"bin":1018, "name":"function findAll(req, res, next) {\n//    console.log(1);\n    var tmpv0 = PROPERTIES;\n    res.json(tmpv0);\n}"};
hashVar["O_findAll"]={"bin":1019, "name":"O_findAll"};
hashVar["findAll"]={"bin":1020, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:139:142"]={"bin":1021, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:144:147"]={"bin":1022, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:149:153"]={"bin":1023, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:183:206"]={"bin":1024, "name":"var tmpv0 = PROPERTIES;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:187:192"]={"bin":1025, "name":"tmpv0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:195:205"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:211:227"]={"bin":1026, "name":"res.json(tmpv0);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:211:214"]={"bin":1022, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:220:225"]={"bin":1025, "name":"tmpv0"};
hashVar["2tempHash"]={"bin":1030, "name":"2tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:229:230"]={"bin":1031, "name":";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:233:426"]={"bin":1032, "name":"function findById(req, res, next) {\n    var temp4 = req.params;\n    var idd2 = temp4.id;\n    var temp5 = idd2-1;\n    var temp6 = PROPERTIES[temp5];\n    var tmpv1 = temp6;\n    res.json(tmpv1);\n}"};
hashVar["O_findById"]={"bin":1033, "name":"O_findById"};
hashVar["findById"]={"bin":1034, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:251:254"]={"bin":1035, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:256:259"]={"bin":1036, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:261:265"]={"bin":1037, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:273:296"]={"bin":1038, "name":"var temp4 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:277:282"]={"bin":1039, "name":"temp4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:285:288"]={"bin":1035, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:285:295"]={"bin":1040, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:289:295"]={"bin":1041, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:301:321"]={"bin":1042, "name":"var idd2 = temp4.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:305:309"]={"bin":1043, "name":"idd2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:312:317"]={"bin":1039, "name":"temp4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:312:320"]={"bin":1044, "name":"temp4.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:318:320"]={"bin":1045, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:326:345"]={"bin":1046, "name":"var temp5 = idd2-1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:330:335"]={"bin":1047, "name":"temp5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:338:342"]={"bin":1043, "name":"idd2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:350:380"]={"bin":1052, "name":"var temp6 = PROPERTIES[temp5];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:354:359"]={"bin":1053, "name":"temp6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:362:372"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:362:379"]={"bin":1054, "name":"PROPERTIES[temp5]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:373:378"]={"bin":1047, "name":"temp5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:385:403"]={"bin":1055, "name":"var tmpv1 = temp6;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:389:394"]={"bin":1056, "name":"tmpv1"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:397:402"]={"bin":1053, "name":"temp6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:408:424"]={"bin":1057, "name":"res.json(tmpv1);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:408:411"]={"bin":1036, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:417:422"]={"bin":1056, "name":"tmpv1"};
hashVar["4tempHash"]={"bin":1061, "name":"4tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:428:605"]={"bin":1062, "name":"function findById(req, res, next) {\n     var tmpv13 = req.params;\n     var id = tmpv13.id;\n     var tmpv10 = id - 1;\n     var tmpv2 = PROPERTIES[tmpv10];\n     res.json(tmpv2);\n}"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:446:449"]={"bin":1063, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:451:454"]={"bin":1064, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:456:460"]={"bin":1065, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:469:493"]={"bin":1066, "name":"var tmpv13 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:473:479"]={"bin":1067, "name":"tmpv13"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:482:485"]={"bin":1063, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:482:492"]={"bin":1068, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:486:492"]={"bin":1069, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:499:518"]={"bin":1070, "name":"var id = tmpv13.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:503:505"]={"bin":1071, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:508:514"]={"bin":1067, "name":"tmpv13"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:508:517"]={"bin":1072, "name":"tmpv13.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:515:517"]={"bin":1073, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:524:544"]={"bin":1074, "name":"var tmpv10 = id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:528:534"]={"bin":1075, "name":"tmpv10"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:537:539"]={"bin":1071, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:550:581"]={"bin":1080, "name":"var tmpv2 = PROPERTIES[tmpv10];"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:554:559"]={"bin":1081, "name":"tmpv2"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:562:572"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:562:580"]={"bin":1082, "name":"PROPERTIES[tmpv10]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:573:579"]={"bin":1075, "name":"tmpv10"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:587:603"]={"bin":1083, "name":"res.json(tmpv2);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:587:590"]={"bin":1064, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:596:601"]={"bin":1081, "name":"tmpv2"};
hashVar["6tempHash"]={"bin":1087, "name":"6tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:609:698"]={"bin":1088, "name":"function getFavorites(req, res, next) {\n    var tmpv3 = favorites;\n    res.json(tmpv3);\n}"};
hashVar["O_getFavorites"]={"bin":1089, "name":"O_getFavorites"};
hashVar["getFavorites"]={"bin":1090, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:631:634"]={"bin":1091, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:636:639"]={"bin":1092, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:641:645"]={"bin":1093, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:653:675"]={"bin":1094, "name":"var tmpv3 = favorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:657:662"]={"bin":1095, "name":"tmpv3"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:665:674"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:680:696"]={"bin":1096, "name":"res.json(tmpv3);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:680:683"]={"bin":1092, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:689:694"]={"bin":1095, "name":"tmpv3"};
hashVar["7tempHash"]={"bin":1100, "name":"7tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:700:1061"]={"bin":1101, "name":"function favorite(req, res, next) {\n    var property = req.body;\n    var exists = false;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }\n    if (!exists) var tmpv4 = property;\n    favorites.push(tmpv4);\n    var tmpv5 = \"success\";\n    res.send(tmpv5)\n}"};
hashVar["O_favorite"]={"bin":1102, "name":"O_favorite"};
hashVar["favorite"]={"bin":1103, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:718:721"]={"bin":1104, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:723:726"]={"bin":1105, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:728:732"]={"bin":1106, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:740:764"]={"bin":1107, "name":"var property = req.body;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:744:752"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:755:758"]={"bin":1104, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:755:763"]={"bin":1109, "name":"req.body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:759:763"]={"bin":1110, "name":"body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:769:788"]={"bin":1111, "name":"var exists = false;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:773:779"]={"bin":1112, "name":"exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:793:946"]={"bin":1117, "name":"for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }\n    }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:798:807"]={"bin":1118, "name":"var i = 0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:809:829"]={"bin":1119, "name":"i < favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:831:834"]={"bin":1120, "name":"i++"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:802:803"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:809:810"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:813:822"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:813:829"]={"bin":1126, "name":"favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:823:829"]={"bin":1127, "name":"length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:831:832"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:846:940"]={"bin":1128, "name":"if (favorites[i].id === property.id) {\n            exists = true;\n            break;\n        }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:881"]={"bin":1129, "name":"favorites[i].id === property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:859"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:850:862"]={"bin":1130, "name":"favorites[i]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:860:861"]={"bin":1121, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:870:878"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:870:881"]={"bin":1131, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:879:881"]={"bin":1132, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:897:911"]={"bin":1133, "name":"exists = true;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:897:903"]={"bin":1112, "name":"exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:924:930"]={"bin":1138, "name":"break;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:951:985"]={"bin":1139, "name":"if (!exists) var tmpv4 = property;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:955:962"]={"bin":1140, "name":"!exists"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:964:985"]={"bin":1141, "name":"var tmpv4 = property;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:968:973"]={"bin":1142, "name":"tmpv4"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:976:984"]={"bin":1108, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:990:1012"]={"bin":1143, "name":"favorites.push(tmpv4);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:990:999"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1005:1010"]={"bin":1142, "name":"tmpv4"};
hashVar["11tempHash"]={"bin":1147, "name":"11tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1017:1039"]={"bin":1148, "name":"var tmpv5 = \"success\";"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1021:1026"]={"bin":1149, "name":"tmpv5"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1044:1059"]={"bin":1154, "name":"res.send(tmpv5)"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1044:1047"]={"bin":1105, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1053:1058"]={"bin":1149, "name":"tmpv5"};
hashVar["13tempHash"]={"bin":1158, "name":"13tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1063:1390"]={"bin":1159, "name":"function unfavorite(req, res, next) {\n    var tmpv14 = req.params;\nvar id = tmpv14.id;\n    for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }\n    var tmpv8 = favorites;\nres.json(tmpv8)\n}"};
hashVar["O_unfavorite"]={"bin":1160, "name":"O_unfavorite"};
hashVar["unfavorite"]={"bin":1161, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1083:1086"]={"bin":1162, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1088:1091"]={"bin":1163, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1093:1097"]={"bin":1164, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1105:1129"]={"bin":1165, "name":"var tmpv14 = req.params;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1109:1115"]={"bin":1166, "name":"tmpv14"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1118:1121"]={"bin":1162, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1118:1128"]={"bin":1167, "name":"req.params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1122:1128"]={"bin":1168, "name":"params"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1130:1149"]={"bin":1169, "name":"var id = tmpv14.id;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1134:1136"]={"bin":1170, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1139:1145"]={"bin":1166, "name":"tmpv14"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1139:1148"]={"bin":1171, "name":"tmpv14.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1146:1148"]={"bin":1172, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1154:1345"]={"bin":1173, "name":"for (var i = 0; i < favorites.length; i++) {\n        if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }\n    }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1159:1168"]={"bin":1174, "name":"var i = 0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1170:1190"]={"bin":1175, "name":"i < favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1192:1195"]={"bin":1176, "name":"i++"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1163:1164"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1170:1171"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1174:1183"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1174:1190"]={"bin":1182, "name":"favorites.length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1184:1190"]={"bin":1183, "name":"length"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1192:1193"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1207:1339"]={"bin":1184, "name":"if (favorites[i].id == id) {\n            var tmpv6 = i;\n\nvar tmpv7 = 1;\nfavorites.splice(tmpv6, tmpv7);\n            break;\n        }"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1232"]={"bin":1185, "name":"favorites[i].id == id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1220"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1211:1223"]={"bin":1186, "name":"favorites[i]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1221:1222"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1230:1232"]={"bin":1170, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1248:1262"]={"bin":1187, "name":"var tmpv6 = i;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1252:1257"]={"bin":1188, "name":"tmpv6"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1260:1261"]={"bin":1177, "name":"i"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1264:1278"]={"bin":1189, "name":"var tmpv7 = 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1268:1273"]={"bin":1190, "name":"tmpv7"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1279:1310"]={"bin":1195, "name":"favorites.splice(tmpv6, tmpv7);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1279:1288"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1296:1301"]={"bin":1188, "name":"tmpv6"};
hashVar["16tempHash"]={"bin":1199, "name":"16tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1303:1308"]={"bin":1190, "name":"tmpv7"};
hashVar["17tempHash"]={"bin":1203, "name":"17tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1323:1329"]={"bin":1204, "name":"break;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1350:1372"]={"bin":1205, "name":"var tmpv8 = favorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1354:1359"]={"bin":1206, "name":"tmpv8"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1362:1371"]={"bin":1013, "name":"favorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1373:1388"]={"bin":1207, "name":"res.json(tmpv8)"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1373:1376"]={"bin":1163, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1382:1387"]={"bin":1206, "name":"tmpv8"};
hashVar["18tempHash"]={"bin":1211, "name":"18tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1392:1605"]={"bin":1212, "name":"function like(req, res, next) {\n    var property = req.body;\n    var tmpv11 = property.id - 1;\nPROPERTIES[tmpv11].likes++;\n    var tmpv12 = property.id - 1;\nvar tmpv9 = PROPERTIES[tmpv12].likes;\nres.json(tmpv9);\n}"};
hashVar["O_like"]={"bin":1213, "name":"O_like"};
hashVar["like"]={"bin":1214, "name":"like"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1406:1409"]={"bin":1215, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1411:1414"]={"bin":1216, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1416:1420"]={"bin":1217, "name":"next"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1428:1452"]={"bin":1218, "name":"var property = req.body;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1432:1440"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1443:1446"]={"bin":1215, "name":"req"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1443:1451"]={"bin":1220, "name":"req.body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1447:1451"]={"bin":1221, "name":"body"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1457:1486"]={"bin":1222, "name":"var tmpv11 = property.id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1461:1467"]={"bin":1223, "name":"tmpv11"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1470:1478"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1470:1481"]={"bin":1224, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1479:1481"]={"bin":1225, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1514"]={"bin":1230, "name":"PROPERTIES[tmpv11].likes++;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1497"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1498:1504"]={"bin":1223, "name":"tmpv11"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1487:1505"]={"bin":1231, "name":"PROPERTIES[tmpv11]"};
hashVar["ttemp0"]={"bin":1232, "name":"ttemp0"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1519:1548"]={"bin":1233, "name":"var tmpv12 = property.id - 1;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1523:1529"]={"bin":1234, "name":"tmpv12"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1532:1540"]={"bin":1219, "name":"property"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1532:1543"]={"bin":1235, "name":"property.id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1541:1543"]={"bin":1236, "name":"id"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1549:1586"]={"bin":1241, "name":"var tmpv9 = PROPERTIES[tmpv12].likes;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1553:1558"]={"bin":1242, "name":"tmpv9"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1561:1571"]={"bin":1008, "name":"PROPERTIES"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1561:1579"]={"bin":1243, "name":"PROPERTIES[tmpv12]"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1572:1578"]={"bin":1234, "name":"tmpv12"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1587:1603"]={"bin":1244, "name":"res.json(tmpv9);"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1587:1590"]={"bin":1216, "name":"res"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1596:1601"]={"bin":1242, "name":"tmpv9"};
hashVar["21tempHash"]={"bin":1248, "name":"21tempHash"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1607:1633"]={"bin":1249, "name":"exports.findAll = findAll;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1607:1614"]={"bin":1250, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1615:1622"]={"bin":1251, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1625:1632"]={"bin":1252, "name":"findAll"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1634:1662"]={"bin":1253, "name":"exports.findById = findById;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1634:1641"]={"bin":1254, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1642:1650"]={"bin":1255, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1653:1661"]={"bin":1256, "name":"findById"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1663:1699"]={"bin":1257, "name":"exports.getFavorites = getFavorites;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1663:1670"]={"bin":1258, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1671:1683"]={"bin":1259, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1686:1698"]={"bin":1260, "name":"getFavorites"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1700:1728"]={"bin":1261, "name":"exports.favorite = favorite;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1700:1707"]={"bin":1262, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1708:1716"]={"bin":1263, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1719:1727"]={"bin":1264, "name":"favorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1729:1761"]={"bin":1265, "name":"exports.unfavorite = unfavorite;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1729:1736"]={"bin":1266, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1737:1747"]={"bin":1267, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1750:1760"]={"bin":1268, "name":"unfavorite"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1762:1782"]={"bin":1269, "name":"exports.like = like;"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1762:1769"]={"bin":1270, "name":"exports"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1770:1774"]={"bin":1271, "name":"like"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:1777:1781"]={"bin":1272, "name":"like"};
hashVar["dVXRLg.js:21:11646"]={"bin":1273, "name":"exports.data = [\n        {\n            id: 1,\n            city: 'Boston',\n            state: 'MA',\n            price: '$475,000',\n            title: 'Condominium Redefined',\n            beds: 2,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 2,\n            city: 'Cambridge',\n            state: 'MA',\n            price: '$1,200,000',\n            title: 'Ultimate Sophistication',\n            beds: 5,\n            baths: 4,\n            likes: 2,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 3,\n            city: 'Boston',\n            state: 'MA',\n            price: '$650,000',\n            title: 'Seaport District Retreat',\n            beds: 3,\n            baths: 2,\n            likes: 6,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 4,\n            city: 'Boston',\n            state: 'MA',\n            price: '$875,000',\n            title: 'Modern City Living',\n            beds: 3,\n            baths: 2,\n            likes: 12,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 5,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$425,000',\n            title: 'Urban Efficiency',\n            beds: 4,\n            baths: 2,\n            likes: 5,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 6,\n            city: 'Boston',\n            state: 'MA',\n            price: '$550,000',\n            title: 'Waterfront in the City',\n            beds: 3,\n            baths: 2,\n            likes: 14,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 7,\n            city: 'Brookline',\n            state: 'MA',\n            zip: '02420',\n            price: '$850,000',\n            title: 'Suburban Extravaganza',\n            beds: 5,\n            baths: 4,\n            likes: 5,\n            broker: {\n                id: 7,\n                name: \"Michelle Lambert\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michelle_lambert.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 8,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$925,000',\n            title: 'Contemporary Luxury',\n            beds: 6,\n            baths: 6,\n            sqft: 950,\n            likes: 8,\n            broker: {\n                id: 8,\n                name: \"Victor Oachoa\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/victor_ochoa.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 9,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$550,000',\n            title: 'Heart of Harvard Square',\n            beds: 5,\n            baths: 4,\n            likes: 9,\n            broker: {\n                id: 1,\n                name: \"Caroline Kingsley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 10,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$375,000',\n            title: 'Architectural Details',\n            beds: 2,\n            baths: 2,\n            likes: 10,\n            broker: {\n                id: 2,\n                name: \"Michael Jones\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 11,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$495,000',\n            title: 'Modern Elegance',\n            beds: 2,\n            baths: 2,\n            likes: 16,\n            broker: {\n                id: 3,\n                name: \"Jonathan Bradley\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 12,\n            city: 'Boston',\n            state: 'MA',\n            zip: '02420',\n            price: '$625,000',\n            title: 'Stunning Colonial',\n            beds: 4,\n            baths: 2,\n            likes: 9,\n            broker: {\n                id: 4,\n                name: \"Jennifer Wu\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 13,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '02420',\n            price: '$430,000',\n            title: 'Quiet Retreat',\n            beds: 5,\n            baths:4,\n            likes: 18,\n            broker: {\n                id: 5,\n                name: \"Olivia Green\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        },\n        {\n            id: 14,\n            city: 'Cambridge',\n            state: 'MA',\n            zip: '01742',\n            price: '$450,000',\n            title: 'Victorian Revival',\n            beds: 4,\n            baths:3,\n            sqft: 3800,\n            likes: 10,\n            broker: {\n                id: 6,\n                name: \"Miriam Aupont\",\n                title: \"Senior Broker\",\n                picture: \"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg\"\n            },\n            pic: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01wide.jpg',\n            thumb: 'https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01sq.jpg',\n            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.'\n        }\n    ];"};
hashVar["dVXRLg.js:21:28"]={"bin":1274, "name":"exports"};
hashVar["dVXRLg.js:29:33"]={"bin":1275, "name":"data"};
hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:49:100"]["name"]="var PROPERTIES = require('./dVXRLg').data;";
code[hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:49:100"]["bin"]]="var PROPERTIES = require('./dVXRLg').data;";
fp.fact(datadep(BitVecVal(hashVar["dVXRLg.js:21:11646"]["bin"],lineNum),BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:49:100"]["bin"],lineNum)))
boundToExtractFunction = 1272;
fp.fact(refs(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:183:206"]["bin"],lineNum),BitVecVal(9114157,val)))
fp.fact(ref(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:187:192"]["bin"],var),BitVecVal(1717943,val)))
#sql statements
value_sid_unmarshal=9114157

exitLine = Const('exit', lineNum)
fp.declare_var(exitLine)

fp.query(unMarshal(line2, v1, 9114157))
v_ex = fp.get_answer()
unmarshal_stmt = v_ex.arg(1).arg(1).as_long()
unmarshal_stmt_start = get_key(unmarshal_stmt).split(":")[1]
print colored("*********** Constraint Solving Started::::",'magenta')
print colored( "unMarshal***********",'blue'), unmarshal_stmt, unmarshal_stmt_start
#
#
fp.query(Marshal(line2, v1, 1717943))
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
    fp.query(ExecutedStmts(exitLine, 12313, 9114157, 1717943))
else:
    fp.query(ExecutedStmts0(exitLine, 9114157, 1717943))

# fp.query(ExecutedStmts(exitLine, 12313, 9114157, 1717943))
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
    #print "myposition", myposition, unmarshal_stmt_start, marshal_stmt_start , int(myposition)>=int(unmarshal_stmt_start)
    if int(myposition)>=int(unmarshal_stmt_start) and int(myposition)<=int(marshal_stmt_start):
        extract_ftn[int(myposition)] = int(v_ex.arg(x).arg(1).as_long());
    #  extract_globals[myposition]= v_ex.arg(x).arg(1).as_long();
    else:
        extract_globals[int(myposition)] = int(v_ex.arg(x).arg(1).as_long());
       # extract_ftn[myposition]=v_ex.arg(x).arg(1).as_long();

#print "extract_ftn", extract_ftn
#print "extract_others", extract_globals

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
if value_sid_unmarshal!=9114157:
    print colored("function "+uid+"(input){","yellow")
    jscode +="function "+uid+"(input){"+"\n"
    adaptedIn = adaptinput(code[unmarshal_stmt],"id")
    if int(unmarshal_stmt) not in extract_ftn.itervalues():
        print colored(adaptedIn, 'blue')
        jscode += adaptedIn + "\n"
else:
    print colored("function "+uid+"(){","yellow")
    jscode +="function "+uid+"(){"+"\n"
    adaptedIn = code[unmarshal_stmt];


for key in sorted(extract_ftn.keys()):
    print colored("\t" + code[extract_ftn[key]], 'yellow')
    jscode += "\t"+code[extract_ftn[key]] + "\n"


print colored(adaptoutput(code[marshal_stmt], loadedVar), 'blue')
jscode +=adaptoutput(code[marshal_stmt], loadedVar) +"\n"


#if int(marshal_stmt) not in extract_ftn.itervalues():
#    print colored(adaptoutput(code[marshal_stmt], loadedVar), 'blue')
#    jscode +=adaptoutput(code[marshal_stmt], loadedVar) +"\n"


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

