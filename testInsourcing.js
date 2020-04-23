var  constraints_solver= require('./src/Insourcing');

var input_donut_id = { sqlInvocations:
   [ { pos: 495,
       end: 555,
       text: 'select * from donuts where id =1',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:474:557"]["bin"]]="var donuts=alasql(tmpv3);"' } ],
  sqlInvocationsloc:
   [ 'subject_apps/Donuts/routes/donutsRoutes.js:474:557',
     'subject_apps/Donuts/routes/donutsRoutes.js:474:557' ],
  sqls: [],
  exit:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:527:533',
     range: [ 527, 533 ],
     val: '[{"id":1,"name":"Glazed","topping":null,"price":2}]',
     value_sid: 6173668,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:519:524"]["bin"],var),BitVecVal(6173668,val)))' },
  entry:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:409:418',
     range: [ 409, 418 ],
     value: 1,
     value_sid: 3062344,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:400:406"]["bin"],var),BitVecVal(3062344,val)))' } };

var insourcing_input_pall = { sqlInvocations: [],
  sqlInvocationsloc: [],
  sqls: [],
  exit:
   { filename: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js',
     filnenamerange: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js:195:205',
     range: [ 195, 205 ],
     val: '[{"id":1,"city":"Boston","state":"MA","price":"$475,000","title":"Condominium Redefined","beds":2,"baths":2,"likes":5,"broker":{"id":1,"name":"Caroline Kingsley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":2,"city":"Cambridge","state":"MA","price":"$1,200,000","title":"Ultimate Sophistication","beds":5,"baths":4,"likes":2,"broker":{"id":2,"name":"Michael Jones","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":3,"city":"Boston","state":"MA","price":"$650,000","title":"Seaport District Retreat","beds":3,"baths":2,"likes":6,"broker":{"id":3,"name":"Jonathan Bradley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":4,"city":"Boston","state":"MA","price":"$875,000","title":"Modern City Living","beds":3,"baths":2,"likes":12,"broker":{"id":4,"name":"Jennifer Wu","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":5,"city":"Boston","state":"MA","zip":"02420","price":"$425,000","title":"Urban Efficiency","beds":4,"baths":2,"likes":5,"broker":{"id":5,"name":"Olivia Green","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":6,"city":"Boston","state":"MA","price":"$550,000","title":"Waterfront in the City","beds":3,"baths":2,"likes":14,"broker":{"id":6,"name":"Miriam Aupont","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":7,"city":"Brookline","state":"MA","zip":"02420","price":"$850,000","title":"Suburban Extravaganza","beds":5,"baths":4,"likes":5,"broker":{"id":7,"name":"Michelle Lambert","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michelle_lambert.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":8,"city":"Boston","state":"MA","zip":"02420","price":"$925,000","title":"Contemporary Luxury","beds":6,"baths":6,"sqft":950,"likes":8,"broker":{"id":8,"name":"Victor Oachoa","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/victor_ochoa.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":9,"city":"Cambridge","state":"MA","zip":"02420","price":"$550,000","title":"Heart of Harvard Square","beds":5,"baths":4,"likes":9,"broker":{"id":1,"name":"Caroline Kingsley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":10,"city":"Boston","state":"MA","zip":"02420","price":"$375,000","title":"Architectural Details","beds":2,"baths":2,"likes":10,"broker":{"id":2,"name":"Michael Jones","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":11,"city":"Boston","state":"MA","zip":"02420","price":"$495,000","title":"Modern Elegance","beds":2,"baths":2,"likes":16,"broker":{"id":3,"name":"Jonathan Bradley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":12,"city":"Boston","state":"MA","zip":"02420","price":"$625,000","title":"Stunning Colonial","beds":4,"baths":2,"likes":9,"broker":{"id":4,"name":"Jennifer Wu","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":13,"city":"Cambridge","state":"MA","zip":"02420","price":"$430,000","title":"Quiet Retreat","beds":5,"baths":4,"likes":18,"broker":{"id":5,"name":"Olivia Green","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":14,"city":"Cambridge","state":"MA","zip":"01742","price":"$450,000","title":"Victorian Revival","beds":4,"baths":3,"sqft":3800,"likes":10,"broker":{"id":6,"name":"Miriam Aupont","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."}]',
     value_sid: 1717943,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:187:192"]["bin"],var),BitVecVal(1717943,val)))' },
  entry:
   { filename: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js',
     filnenamerange: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js:183:206',
     range: [ 183, 206 ],
     value: 'JSRCIStr',
     value_sid: 9114157,
     rwfacts: 'fp.fact(refs(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:183:206"]["bin"],lineNum),BitVecVal(9114157,val)))' } }


var input_pall2 = { sqlInvocations: [],
  sqlInvocationsloc: [],
  sqls: [],
  exit:
   { filename: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js',
     filnenamerange: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js:164:174',
     range: [ 164, 174 ],
     val: '[{"id":1,"city":"Boston","state":"MA","price":"$475,000","title":"Condominium Redefined","beds":2,"baths":2,"likes":5,"broker":{"id":1,"name":"Caroline Kingsley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house08sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":2,"city":"Cambridge","state":"MA","price":"$1,200,000","title":"Ultimate Sophistication","beds":5,"baths":4,"likes":2,"broker":{"id":2,"name":"Michael Jones","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house02sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":3,"city":"Boston","state":"MA","price":"$650,000","title":"Seaport District Retreat","beds":3,"baths":2,"likes":6,"broker":{"id":3,"name":"Jonathan Bradley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house09sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":4,"city":"Boston","state":"MA","price":"$875,000","title":"Modern City Living","beds":3,"baths":2,"likes":12,"broker":{"id":4,"name":"Jennifer Wu","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house14sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":5,"city":"Boston","state":"MA","zip":"02420","price":"$425,000","title":"Urban Efficiency","beds":4,"baths":2,"likes":5,"broker":{"id":5,"name":"Olivia Green","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house03sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":6,"city":"Boston","state":"MA","price":"$550,000","title":"Waterfront in the City","beds":3,"baths":2,"likes":14,"broker":{"id":6,"name":"Miriam Aupont","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house05sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":7,"city":"Brookline","state":"MA","zip":"02420","price":"$850,000","title":"Suburban Extravaganza","beds":5,"baths":4,"likes":5,"broker":{"id":7,"name":"Michelle Lambert","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michelle_lambert.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house07sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":8,"city":"Boston","state":"MA","zip":"02420","price":"$925,000","title":"Contemporary Luxury","beds":6,"baths":6,"sqft":950,"likes":8,"broker":{"id":8,"name":"Victor Oachoa","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/victor_ochoa.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house12sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":9,"city":"Cambridge","state":"MA","zip":"02420","price":"$550,000","title":"Heart of Harvard Square","beds":5,"baths":4,"likes":9,"broker":{"id":1,"name":"Caroline Kingsley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/caroline_kingsley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house10sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":10,"city":"Boston","state":"MA","zip":"02420","price":"$375,000","title":"Architectural Details","beds":2,"baths":2,"likes":10,"broker":{"id":2,"name":"Michael Jones","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house11sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":11,"city":"Boston","state":"MA","zip":"02420","price":"$495,000","title":"Modern Elegance","beds":2,"baths":2,"likes":16,"broker":{"id":3,"name":"Jonathan Bradley","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jonathan_bradley.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house13sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":12,"city":"Boston","state":"MA","zip":"02420","price":"$625,000","title":"Stunning Colonial","beds":4,"baths":2,"likes":9,"broker":{"id":4,"name":"Jennifer Wu","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house06sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":13,"city":"Cambridge","state":"MA","zip":"02420","price":"$430,000","title":"Quiet Retreat","beds":5,"baths":4,"likes":18,"broker":{"id":5,"name":"Olivia Green","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/olivia_green.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house04sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."},{"id":14,"city":"Cambridge","state":"MA","zip":"01742","price":"$450,000","title":"Victorian Revival","beds":4,"baths":3,"sqft":3800,"likes":10,"broker":{"id":6,"name":"Miriam Aupont","title":"Senior Broker","picture":"https://s3-us-west-1.amazonaws.com/sfdc-demo/people/miriam_aupont.jpg"},"pic":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01wide.jpg","thumb":"https://s3-us-west-1.amazonaws.com/sfdc-demo/realty/house01sq.jpg","description":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad."}]',
     value_sid: 1717943,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:156:161"]["bin"],var),BitVecVal(1717943,val)))' },
  entry:
   { filename: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js',
     filnenamerange: 'subject_apps/ionic2-realty-rest/server/norm_property-service.js:152:175',
     range: [ 152, 175 ],
     value: 'JSRCIStr',
     value_sid: 9114157,
     rwfacts: 'fp.fact(refs(BitVecVal(hashVar["subject_apps/ionic2-realty-rest/server/norm_property-service.js:152:175"]["bin"],lineNum),BitVecVal(9114157,val)))' } }

var input_donuts = { sqlInvocations:
   [ { pos: 244,
       end: 304,
       text: 'select * from donuts',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:223:306"]["bin"]]="var donuts=alasql(tmpv0);"' } ],
  sqlInvocationsloc:
   [ 'subject_apps/Donuts/routes/donutsRoutes.js:223:306',
     'subject_apps/Donuts/routes/donutsRoutes.js:223:306' ],
  sqls: [],
  exit:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:276:282',
     range: [ 276, 282 ],
     val: '[{"id":1,"name":"Glazed","topping":null,"price":2},{"id":2,"name":"Long John","topping":"Maple","price":3},{"id":3,"name":"Frosted","topping":"Strawberry","price":2}]',
     value_sid: 4047092,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:268:273"]["bin"],var),BitVecVal(4047092,val)))' },
  entry:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:187:222',
     range: [ 187, 222 ],
     value: 'JSRCIStr',
     value_sid: 9114157,
     rwfacts: 'fp.fact(refs(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:187:222"]["bin"],lineNum),BitVecVal(9114157,val)))' } }


var input_del={ sqlInvocations:
   [ { pos: 1583,
       end: 1770,
       text: 'delete from donuts WHERE id =1',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1561:1772"]["bin"]]="alasql(tmpv14);"' },
     { pos: 1670,
       end: 1760,
       text: 'select * from donuts',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1648:1762"]["bin"]]="var donuts=alasql(tmpv15);"' }
  ],
  sqlInvocationsloc:
   [ 'subject_apps/Donuts/routes/donutsRoutes.js:1561:1772',
     'subject_apps/Donuts/routes/donutsRoutes.js:1648:1762' ],
  sqls: [],
  exit:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:1713:1719',
     range: [ 1713, 1719 ],
     val: '[{"id":2,"name":"Long John","topping":"Maple","price":3},{"id":3,"name":"Frosted","topping":"Strawberry","price":2}]',
     value_sid: 7331090,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1704:1710"]["bin"],var),BitVecVal(7331090,val)))' },
  entry:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:1489:1498',
     range: [ 1489, 1498 ],
     value: 1,
     value_sid: 3062344,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1480:1486"]["bin"],var),BitVecVal(3062344,val)))' } };

var input_add_donut = { sqlInvocations:
   [ { pos: 804,
       end: 963,
       text: 'insert into donuts (name,topping,price) values( \'donut4\' , \'sugar\' , \'3 \')',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'TABLE',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:783:965"]["bin"]]="alasql(tmpv6);"' },
     { pos: 881,
       end: 957,
       text: 'select * from donuts',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:860:959"]["bin"]]="var donuts=alasql(tmpv7);"' } ],
  sqlInvocationsloc:
   [ 'subject_apps/Donuts/routes/donutsRoutes.js:783:965',
     'subject_apps/Donuts/routes/donutsRoutes.js:860:959' ],
  sqls: [],
  entry:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:638:646',
     range: [ 638, 646 ],
     value: { name: 'donut4', topping: 'sugar', price: 3 },
     value_sid: 6858781,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:629:635"]["bin"],var),BitVecVal(6858781,val)))' },
  exit:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:919:925',
     range: [ 919, 925 ],
     val: '[{"id":1,"name":"Glazed","topping":null,"price":2},{"id":2,"name":"Long John","topping":"Maple","price":3},{"id":3,"name":"Frosted","topping":"Strawberry","price":2},{"id":6,"name":"donut4","topping":"sugar","price":3}]',
     value_sid: 207651,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:911:916"]["bin"],var),BitVecVal(207651,val)))' } };

var input_update_donut = { sqlInvocations:
   [ { pos: 1242,
       end: 1421,
       text: 'update donuts set name = \'Short John\', topping = \'Sugar\' WHERE id = 2',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'TABLE',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1220:1423"]["bin"]]="alasql(tmpv10);"' },
     { pos: 1329,
       end: 1415,
       text: 'select * from donuts',
       file: '/Users/kijin/projects/public/public_artifact/tmp/JS-RCI/subject_apps/Donuts/routes/donutsRoutes.js',
       argf: '',
       tablename: 'donuts',
       adaptedsqlInvocation: 'code[hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1307:1417"]["bin"]]="var donuts=alasql(tmpv11);"' } ],
  sqlInvocationsloc:
   [ 'subject_apps/Donuts/routes/donutsRoutes.js:1220:1423',
     'subject_apps/Donuts/routes/donutsRoutes.js:1307:1417' ],
  sqls: [],
  entry:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:1053:1061',
     range: [ 1053, 1061 ],
     value: { id: 2, name: 'Short John', topping: 'Sugar' },
     value_sid: 7617015,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1044:1050"]["bin"],var),BitVecVal(7617015,val)))' },
  exit:
   { filename: 'subject_apps/Donuts/routes/donutsRoutes.js',
     filnenamerange: 'subject_apps/Donuts/routes/donutsRoutes.js:1372:1378',
     range: [ 1372, 1378 ],
     val: '[{"id":1,"name":"Glazed","topping":null,"price":2},{"id":2,"name":"Short John","topping":"Sugar","price":3},{"id":3,"name":"Frosted","topping":"Strawberry","price":2}]',
     value_sid: 5644345,
     rwfacts: 'fp.fact(ref(BitVecVal(hashVar["subject_apps/Donuts/routes/donutsRoutes.js:1363:1369"]["bin"],var),BitVecVal(5644345,val)))' } };


console.log(constraints_solver(insourcing_input_pall));
// console.log(constraints_solver(input_donut_id));
// console.log(constraints_solver(input_donuts));
// console.log(constraints_solver(input_del));

//console.log(constraints_solver(input_add_donut));
//console.log(constraints_solver(input_update_donut));



