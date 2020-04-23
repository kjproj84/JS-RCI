(set-option :fixedpoint.engine datalog)

(define-sort var () (_ BitVec 16))
(define-sort obj () (_ BitVec 16))
(define-sort prop () (_ BitVec 16))
(define-sort num () (_ BitVec 16))
(define-sort lineNum () (_ BitVec 16))
(define-sort evType () (_ BitVec 16))

;;;;;;; definitions ;;;;;;;
; Assign (variable variable line#)
; a = b
(declare-rel Assign (var var lineNum))
; Load (variable property variable line#)
; a.b = c
(declare-rel Load (var prop var lineNum))
; Store (variable variable property line#)
; a = b.c;
(declare-rel Store (var var prop lineNum))

; Read1 (variable line#)
(declare-rel Read1 (var lineNum))
; Read2 (variable property line#)
(declare-rel Read2 (var prop lineNum))
; Write1 (variable line#)
(declare-rel Write1 (var lineNum))
; Write2 (variable property line#)
(declare-rel Write2 (var prop lineNum))

; PtsTo (variable object)
(declare-rel PtsTo (var obj))
; HeapPtsTo (variable property object)
(declare-rel HeapPtsTo (var prop obj))

; Stmt (line# object)
(declare-rel Stmt (lineNum obj))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Formal (object number variable)
(declare-rel Formal (obj num var))
; Actual (line# number var)
(declare-rel Actual (lineNum num var))
; MethodRet (object variable)
(declare-rel MethodRet(obj var))
; CallRet (line# variable)
(declare-rel CallRet (lineNum var))
; Calls (object line#)
(declare-rel Calls (obj lineNum))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FuncDecl (variable object line#)
(declare-rel FuncDecl (var obj lineNum))
; Heap (variable object)
(declare-rel Heap (var obj))
; Dom (variable object)
(declare-rel Dom (var obj))
; DomRead (variable line#)
(declare-rel DomRead (var lineNum))
; DomWrite (variable line#)
(declare-rel DomWrite (var lineNum))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data-dep (line# line#)
(declare-rel data-dep (lineNum lineNum))
; con-dep (line# line#)
(declare-rel control-dep (lineNum lineNum))
; stmt-dep (line# line#)
(declare-rel stmt-dep (lineNum lineNum))
; call-dep (variable variable)
(declare-rel call-dep (var var))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dom-install (variable eventType variable line#)
(declare-rel dom-install (var evType var lineNum))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; dom-data-dep (object eventType object eventType)
(declare-rel dom-data-dep (obj evType obj evType))
; dom-install-dep (object eventType object eventType)
(declare-rel dom-install-dep (obj evType obj evType))
; dom-dep (object eventType object eventType)
(declare-rel dom-dep (obj evType obj evType))


;;;;;;; rules ;;;;;;;
(declare-var o1 obj)
(declare-var o2 obj)
(declare-var o3 obj)
(declare-var o4 obj)
(declare-var v1 var)
(declare-var event1 evType)
(declare-var v2 var)
(declare-var event2 evType)
(declare-var line1 lineNum)
(declare-var v3 var)
(declare-var v4 var)
(declare-var v5 var)
(declare-var v6 var)
(declare-var f1 prop)
(declare-var i1 num)
(declare-var line2 lineNum)
(declare-var line3 lineNum)
(declare-var line4 lineNum)

;;; pointsTo rule ;;;
(rule (=> (Heap v1 o1) (PtsTo v1 o1))) 
(rule (=> (FuncDecl v1 o1 line1) (PtsTo v1 o1)))
(rule (=> (Dom v1 o1) (PtsTo v1 o1)))
(rule (=> (DomRead v1 line1) (PtsTo v1 o1)))
(rule (=> (and
            (PtsTo v1 o1)
            (Assign v2 v1 line1))
           (PtsTo v2 o1)))

;;; Stmt rule ;;;
(rule (=> (and
            (Stmt line1 o2)
            (call-dep o1 o2))
           (Stmt line1 o1)))

;;; call graph ;;;
(rule (=> (and
            (Actual line1 #x0000 v1)
            (PtsTo v1 o1))
           (Calls o1 line1)))



;;; Heap rules ;;;
(rule (=> (and
            (Store v1 f1 v2 line1)
            (PtsTo v1 o1)
            (PtsTo v2 o2))
           (HeapPtsTo o1 f1 o2)))
(rule (=> (and
            (Load v2 v1 f1 line1)
            (PtsTo v1 o1)
            (HeapPtsTo o1 f1 o2))
           (PtsTo v2 o2)))

;;; Interprocedural rules ;;;
(rule (=> (and 
            (Calls o1 line1)
            (Formal o1 i1 v1)
            (Actual line1 i1 v2))
           (Assign v1 v2 line1)))
(rule (=> (and 
            (Calls o1 line1)
            (Formal o1 i1 v1)
            (Actual line1 i1 v2))
           (Read1 v2 line1)))
(rule (=> (and 
            (Calls o1 line1)
            (Formal o1 i1 v1)
            (Actual line1 i1 v2))
           (Write1 v1 line1)))
(rule (=> (and
            (Calls o1 line1)
            (MethodRet o1 v1)
            (CallRet line1 v2))
           (Assign v2 v1 line1)))
(rule (=> (and
            (Calls o1 line1)
            (MethodRet o1 v1)
            (CallRet line1 v2))
           (Read1 v1 line1)))
(rule (=> (and
            (Calls o1 line1)
            (MethodRet o1 v1)
            (CallRet line1 v2))
           (Write1 v2 line1)))

;;; data-dep ;;;
;; Write1 - Read1
(rule (=> (and
            (Write1 v1 line1)
            (Read1 v1 line2))
           (data-dep line1 line2)))
;; Write1 - Read2
(rule (=> (and
            (Write1 v1 line1)
            (Read2 v1 f1 line2))
           (data-dep line1 line2)))
;; Write2 - Read1
(rule (=> (and
            (Write2 v1 f1 line1)
            (Read1 v2 line2)
            (PtsTo v1 o1)
            (PtsTo v2 o1))
           (data-dep line1 line2)))
;; Write2 - Read2 case1 (same name)
(rule (=> (and
            (Write2 v1 f1 line1)
            (Read2 v1 f1 line2))
           (data-dep line1 line2)))
;; Write2 - Read2 case2 (same pointer with same name field)
(rule (=> (and
            (Write2 v1 f1 line1)
            (Read2 v2 f1 line2)
            (PtsTo v1 o1)
            (PtsTo v2 o2))
           (data-dep line1 line2)))
;; transitive
(rule (=> (and
            (data-dep line1 line2)
            (data-dep line2 line3))
           (data-dep line1 line3)))

;;; stmt-dep ;;;
;(rule (=> (data-dep line1 line2) (stmt-dep line1 line2)))
(rule (=> (control-dep line1 line2) (stmt-dep line1 line2)))
(rule (=> (and
            (stmt-dep line1 line2)
            (stmt-dep line2 line3))
           (stmt-dep line1 line3)))

;;; call-dep ;;;
(rule (=> (and
            (Calls o1 line1)
            (Stmt line1 o2))
           (call-dep o2 o1)))
(rule (=> (and
            (call-dep o1 o2)
            (call-dep o2 o3))
           (call-dep o1 o3)))

;;; dom-data-dep ;;;
(rule (=> (and 
            (dom-install v1 event1 v2 line1)
            (PtsTo v1 o1)
            (Dom v3 o1)
            (PtsTo v2 o2)
            (dom-install v4 event2 v5 line2)
            (PtsTo v4 o3)
            (Dom v6 o3)
            (PtsTo v5 o4)
            (data-dep line3 line4)
            (Stmt line3 o2)
            (Stmt line4 o4))
           (dom-data-dep v3 event1 v6 event2)))

;;; dom-install-dep ;;;
(rule (=> (and
            (dom-install v1 event1 v2 line1)
            (PtsTo v1 o1)
            (Dom v3 o1)
            (PtsTo v2 o2)
            (dom-install v4 event2 v5 line2)
            (PtsTo v4 o3)
            (Dom v6 o3)
            (PtsTo v5 o4)
            (Stmt line2 o2))
           (dom-install-dep v3 event1 v6 event2)))

;;; dom-dep ;;;
(rule (=> (dom-data-dep v1 event1 v2 event2) (dom-dep v1 event1 v2 event2)))
(rule (=> (dom-install-dep v1 event1 v2 event2) (dom-dep v1 event1 v2 event2)))

;;;;;; Begin Facts ;;;;;;


(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
;Assignment: exports.findById = findById;
(rule (Write2 #x04b4 #x03fa #x003e ))
(rule (Read1 #x04ba #x003e))
(rule (Store #x04b4 #x03fa #x04b9 #x003e ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
;Assignment: exports.findById = findById;
(rule (Write2 #x04b4 #x03fa #x003e ))
(rule (Read1 #x04ba #x003e))
(rule (Store #x04b4 #x03fa #x04b9 #x003e ))
;Assignment: exports.getFavorites = getFavorites;
(rule (Write2 #x04b8 #x042a #x003f ))
(rule (Read1 #x04be #x003f))
(rule (Store #x04b8 #x042a #x04bd #x003f ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
;Assignment: exports.findById = findById;
(rule (Write2 #x04b4 #x03fa #x003e ))
(rule (Read1 #x04ba #x003e))
(rule (Store #x04b4 #x03fa #x04b9 #x003e ))
;Assignment: exports.getFavorites = getFavorites;
(rule (Write2 #x04b8 #x042a #x003f ))
(rule (Read1 #x04be #x003f))
(rule (Store #x04b8 #x042a #x04bd #x003f ))
;Assignment: exports.favorite = favorite;
(rule (Write2 #x04bc #x0434 #x0040 ))
(rule (Read1 #x04c2 #x0040))
(rule (Store #x04bc #x0434 #x04c1 #x0040 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
;Assignment: exports.findById = findById;
(rule (Write2 #x04b4 #x03fa #x003e ))
(rule (Read1 #x04ba #x003e))
(rule (Store #x04b4 #x03fa #x04b9 #x003e ))
;Assignment: exports.getFavorites = getFavorites;
(rule (Write2 #x04b8 #x042a #x003f ))
(rule (Read1 #x04be #x003f))
(rule (Store #x04b8 #x042a #x04bd #x003f ))
;Assignment: exports.favorite = favorite;
(rule (Write2 #x04bc #x0434 #x0040 ))
(rule (Read1 #x04c2 #x0040))
(rule (Store #x04bc #x0434 #x04c1 #x0040 ))
;Assignment: exports.unfavorite = unfavorite;
(rule (Write2 #x04c0 #x0468 #x0041 ))
(rule (Read1 #x04c6 #x0041))
(rule (Store #x04c0 #x0468 #x04c5 #x0041 ))
(rule (Dom undefined undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var dummyvar;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var PROPERTIES = require('./mock-properties').data;
(rule (Write1 #x03ea #x0001))
(rule (Read2 #x03eb #x03ed #x0001 ))
(rule (Load  undefined undefined #x0001 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findAll
(rule (FuncDecl undefined undefined #x0002 ))
(rule (Formal undefined #x0001 undefined ))
(rule (Formal undefined #x0002 undefined ))
(rule (Formal undefined #x0003 undefined ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv0 = PROPERTIES;
(rule (Read1 #x03f6 #x0003))
(rule (Assign  11#x03ea11 #x0003 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl undefined undefined #x0006 ))
(rule (Formal undefined #x0001 #x03f1 ))
(rule (Formal undefined #x0002 #x03f2 ))
(rule (Formal undefined #x0003 #x03f3 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp4 = req.params;
(rule (Write1 #x03ff #x0007))
(rule (Read2 #x03fb #x0401 #x0007 ))
(rule (Load  #x03fb undefined #x0007 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var idd2 = temp4.id;
(rule (Write1 #x0403 #x0008))
(rule (Read2 #x03ff #x0405 #x0008 ))
(rule (Load  #x03ff undefined #x0008 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp5 = idd2-1;
(rule (Write1 #x0407 #x0009))
(rule (Write1 #x0407 #x0009))
(rule (Read1 #x0408 #x0009))
(rule (Assign #x0407 11#x040311 #x0009 ))
(rule (Write1 #x0407 #x0009))
(rule (Heap #x0408 #x0409 ))
(rule (Assign #x0407 11#x040b11 #x0009 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var temp6 = PROPERTIES[temp5];
(rule (Write1 #x040d #x000a))
(rule (Read2 #x03ea #x0407 #x000a ))
(rule (Load  #x03f6 #x0407 #x000a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv1 = temp6;
(rule (Read1 #x0411 #x000b))
(rule (Assign  11#x040d11 #x000b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: findById
(rule (FuncDecl #x03fa #x03f9 #x000d ))
(rule (Formal #x03f9 #x0001 #x0400 ))
(rule (Formal #x03f9 #x0002 #x03fc ))
(rule (Formal #x03f9 #x0003 #x03fd ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv13 = req.params;
(rule (Read2 #x0413 #x0419 #x000e ))
(rule (Load  #x0413 #x0401 #x000e ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv13.id;
(rule (Write1 #x041b #x000f))
(rule (Read2 #x0417 #x041d #x000f ))
(rule (Load #x0405 #x0417 #x041b #x000f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv10 = id - 1;
(rule (Read1 #x0420 #x0010))
(rule (Assign #x041f 11#x041b11 #x0010 ))
(rule (Heap #x0420 #x0421 ))
(rule (Assign #x041f 11#x042311 #x0010 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv2 = PROPERTIES[tmpv10];
(rule (Read2 #x03ea #x041f #x0011 ))
(rule (Load  #x040e #x041f #x0011 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: getFavorites
(rule (FuncDecl undefined undefined #x0013 ))
(rule (Formal undefined #x0001 #x0418 ))
(rule (Formal undefined #x0002 #x0414 ))
(rule (Formal undefined #x0003 #x0415 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv3 = favorites;
(rule (Read1 #x0430 #x0014))
(rule (Assign  11#x043011 #x0014 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: favorite
(rule (FuncDecl undefined undefined #x0016 ))
(rule (Formal undefined #x0001 #x042b ))
(rule (Formal undefined #x0002 #x042c ))
(rule (Formal undefined #x0003 #x042d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0439 #x0017))
(rule (Read2 #x0435 #x043b #x0017 ))
(rule (Load  #x0435 undefined #x0017 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var exists = false;
(rule (Write1 #x043d #x0018))
(rule (Heap #x043e #x043f ))
(rule (Assign  11#x044111 #x0018 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0446 #x001a))
(rule (Heap #x0447 #x0448 ))
(rule (Assign  11#x044a11 #x001a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x044b #x001b))
(rule (Assign  11#x044611 #x001b ))
(rule (Read2 #x044b #x044d #x001b ))
(rule (Load  #x0430 undefined #x001b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x044e #x001c))
(rule (Read1 #x044e #x001c))
(rule (Assign #x044b 11#x044611 #x001c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id === property.id
(rule (Read2 #x0450 #x0446 #x001e ))
(rule (Load  #x044b #x044e #x001e ))
(rule (Read2 #x0439 #x0453 #x001e ))
(rule (Load  #x0439 #x0420 #x001e ))
;Assignment: exists = true;
(rule (Write1 #x0455 #x001f))
(rule (Heap #x0455 #x0456 ))
(rule (Assign #x043d 11#x045811 #x001f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv4 = property;
(rule (Read1 #x045e #x0023))
(rule (Assign  11#x043911 #x0023 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv5 = \"success\";
(rule (Heap #x0461 #x0462 ))
(rule (Assign  11#x046411 #x0025 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: unfavorite
(rule (FuncDecl undefined undefined #x0027 ))
(rule (Formal undefined #x0001 #x043a ))
(rule (Formal undefined #x0002 #x0436 ))
(rule (Formal undefined #x0003 #x0437 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv14 = req.params;
(rule (Read2 #x0469 #x046f #x0028 ))
(rule (Load  #x0469 #x0419 #x0028 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var id = tmpv14.id;
(rule (Write1 #x0471 #x0029))
(rule (Read2 #x046d #x0473 #x0029 ))
(rule (Load #x0453 #x046d #x0471 #x0029 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var i = 0
(rule (Write1 #x0478 #x002b))
(rule (Heap #x0479 #x047a ))
(rule (Assign #x0452 11#x047c11 #x002b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: i < favorites.length
(rule (Read1 #x047d #x002c))
(rule (Assign  11#x047811 #x002c ))
(rule (Read2 #x047d #x047f #x002c ))
(rule (Load  #x0450 #x044d #x002c ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: i++
(rule (Write1 #x0480 #x002d))
(rule (Read1 #x0480 #x002d))
(rule (Assign #x047d 11#x047811 #x002d ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BinaryExpression: favorites[i].id == id
(rule (Read2 #x0482 #x0478 #x002f ))
(rule (Load  #x047d #x0480 #x002f ))
(rule (Read1 #x0484 #x002f))
(rule (Assign  11#x047111 #x002f ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv6 = i;
(rule (Read1 #x0486 #x0030))
(rule (Assign  11#x047811 #x0030 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv7 = 1;
(rule (Heap #x0488 #x0489 ))
(rule (Assign  11#x048b11 #x0031 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv8 = favorites;
(rule (Read1 #x0490 #x0034))
(rule (Assign  11#x049011 #x0034 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functionDeclaration: like
(rule (FuncDecl undefined undefined #x0036 ))
(rule (Formal undefined #x0001 #x046e ))
(rule (Formal undefined #x0002 #x046a ))
(rule (Formal undefined #x0003 #x046b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var property = req.body;
(rule (Write1 #x0499 #x0037))
(rule (Read2 #x0495 #x049b #x0037 ))
(rule (Load #x045e #x0495 #x043b #x0037 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv11 = property.id - 1;
(rule (Read2 #x0499 #x049f #x0038 ))
(rule (Load #x049d #x0499 #x0484 #x0038 ))
(rule (Heap #x04a0 #x04a1 ))
(rule (Assign #x049d 11#x04a311 #x0038 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;UpdateExpression: PROPERTIES[tmpv11].likes++;
(rule (Write2 #x0426 #x049d #x0039 ))
(rule (Read2 #x03ea #x049d #x0039 ))
(rule (Load undefined #x04a5 #x04a5 #x0039 ))
(rule (Store #x0426 #x049d undefined #x0039 ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv12 = property.id - 1;
(rule (Read2 #x0499 #x04aa #x003a ))
(rule (Load #x04a8 #x049e #x049f #x003a ))
(rule (Heap #x04ab #x04ac ))
(rule (Assign #x04a8 11#x04ae11 #x003a ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;VariableDecl: var tmpv9 = PROPERTIES[tmpv12].likes;
(rule (Read2 #x03ea #x04a8 #x003b ))
(rule (Load  #x04a5 #x04a8 #x003b ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Assignment: exports.findAll = findAll;
(rule (Write2 undefined #x03f0 #x003d ))
(rule (Read1 #x04b6 #x003d))
(rule (Store undefined #x03f0 #x04b5 #x003d ))
;Assignment: exports.findById = findById;
(rule (Write2 #x04b4 #x03fa #x003e ))
(rule (Read1 #x04ba #x003e))
(rule (Store #x04b4 #x03fa #x04b9 #x003e ))
;Assignment: exports.getFavorites = getFavorites;
(rule (Write2 #x04b8 #x042a #x003f ))
(rule (Read1 #x04be #x003f))
(rule (Store #x04b8 #x042a #x04bd #x003f ))
;Assignment: exports.favorite = favorite;
(rule (Write2 #x04bc #x0434 #x0040 ))
(rule (Read1 #x04c2 #x0040))
(rule (Store #x04bc #x0434 #x04c1 #x0040 ))
;Assignment: exports.unfavorite = unfavorite;
(rule (Write2 #x04c0 #x0468 #x0041 ))
(rule (Read1 #x04c6 #x0041))
(rule (Store #x04c0 #x0468 #x04c5 #x0041 ))
;Assignment: exports.like = like;
(rule (Write2 #x04c4 #x0494 #x0042 ))
(rule (Read1 #x04ca #x0042))
(rule (Store #x04c4 #x0494 #x04c9 #x0042 ))
