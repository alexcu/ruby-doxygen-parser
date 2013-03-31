Doxyparser
================

Ruby library that uses Doxygen XML output to parse and query C++ header files.

This library is based on Nokogiri (http://nokogiri.org) and takes as input the xml directory previously generated by Doxygen (www.doxygen.org)

Using Doxygen allows us to parse even a set of non-compilable include files. This is very useful in case you need to parse only a subset of a big library which doesn't compile because of being incomplete or needing configuration through Makefiles, CMake, etc. In those cases parsing with gccxml, swig or others would throw lots of compilation errors.

As work is ongoing, so far there is no much documentation. You are encouraged to improve this library at anytime.


Use Examples:
================


- Parses a whole node (namespace, class, struct, header-file or doxygen-group) from Doxygen generated XML files:

	xmldir= "my/path/to/doxygen/xml"
	clazz = Doxyparser::parse_class("MyNamespace::MyClass", xmldir)
    	group = Doxyparser::parse_group("Animation", xmldir)
	namespace = Doxyparser::parse_namespace("MyNamespace", xmldir)
	struct = Doxyparser::parse_struct("MyNamespace::MyClass::InnerStruct", xmldir)
	hfile = Doxyparser::parse_header_file("test.h", xmldir)


- Gets a reference back to the doxygen generated XML file used to create this node

	puts namespace.path # >/path/to/doxygen/generated/xml-directory/namespaceMyNamespace.xml
	puts clazz.path # >/path/to/doxygen/generated/xml-directory/classMyNamespace_1_1MyClass.xml
	...and similarly for other nodes

- Gets other properties

	puts struct.name # > MyNamespace::MyClass::InnerStruct
	puts struct.basename # > InnerStruct
	puts struct.file # > test.h
	...and similarly for other nodes
	
- It is also possible to get children node objects (namespace, class, etc)
	
	my_methods = clazz.methods('protected')
	my_class_enums = namespace.classes[0].innerenums
	other_file_classes = clazz.file.classes 


Namespaces:
================

- Returns all (direct) namespace members:

	my_global_functions = namespace.functions # Note that the related XML file is now lazily parsed and not at object creation
	my_global_variables = namespace.variables
	my_classes = namespace.classes
	my_inner_namespaces = namespace.innernamespaces
	my_structs = namespace.structs	
	my_enums = namespace.enums

- All of the above can also make optional use of filters and access modifiers (public by default)

	functions=namespace.functions('public', ["function1","function2","etc.."])


Classes:
================


- Returns all (direct) class members:

	my_methods = clazz.methods
	my_attributes = clazz.attributes
	my_inner_classes = clazz.innerclasses
	my_inner_structs = clazz.innerstructs
	my_inner_enums = clazz.innerenums

- All of the above can also make optional use of filters and access modifiers (public by default)

	methods=clazz.methods('protected',["method1","method2","etc.."])

- Getting class properties:

	class1=my_namespace.classes[0]

	puts class1.parent.name # >MyNamespace

	puts class1.name # > MyNamespace::Class1

	puts class1.prot # > "public"

- Gets a reference to the doxygen generated XML file with the description of the class
	puts class1.path # >/path/to/doxygen/generated/xml-directory/classMyNamespace_1_1Class1.xml

- Gets a class' header file:

	file = class1.file

	puts file.name # >myHeaderFile.h

	puts file.path # >/path/to/doxygen/generated/xml-directory/myIncludeFile_8h.xml


- Gets classes and functions also included in the same file by lazily parsing myIncludeFile_8h.xml:

	other_classes = file.classes # > (List of classes defined in this header file)

	puts file.functions # > (List of functions defined in this header file)


Structs:
================

	my_struct = class1.innerstructs[0]
	my_struct.members # > (List of struct members)

- Getting struct properties is similar to getting class' properties

- Gets a struct header file:

	file = my_struct.file


Functions, Methods, Variables, Attributes and Enums:
================

- Gets properties:

	puts myMethod.name 		# > myMethod

	puts myMethod.parent.name 	# > MyNamespace::Class1

	puts myMethod.location 		# > /path/to/included/file/myIncludeFile.h:245

	puts myMethod.definition	# > virtual void MyNamespace::Class1::myMethod

	puts myMethod.args		# > (const Any &anything)


- Functions and Methods only:

	puts myFunction.params.join(",")	# > const String &, const Any &

- Methods only

	puts myMethod.constructor?	# > false

	puts myMethod.destructor?	# > false

- Enums only
	
	puts myEnum.values.join(", ")	# > VAL_A, VAL_B, VAL_C

	
