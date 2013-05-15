require 'rubygems'
require 'rspec'
require 'doxyparser'

require_relative 'custom_spec_helper'

describe "Doxyparser::Class" do

	context "Basic - Creation" do

		it "should create consistently classes from diferent namespaces" do

			klass_syms = { templateClass: "MyNamespace::TemplateClass",
				myClass: "MyNamespace::MyClass",
				myClass_inner: "MyNamespace::MyInnerNamespace::MyMostInnerNamespace::MyClass",
				innerClass: "MyNamespace::MyClass::InnerClass"}

			struct_syms = { outerStruct: "MyNamespace::OuterStruct",
				innerStruct: "MyNamespace::MyClass::InnerStruct"}

			klasses = {}

			klass_syms.each_key {|k|
				klasses[k] = Doxyparser::parse_class(klass_syms[k], xml_dir)
			}

			struct_syms.each_key {|k|
				klasses[k] = Doxyparser::parse_struct(struct_syms[k], xml_dir)
			}

			klasses.each {|k, v|
				v.file.basename.should eql "test1.h"
				v.file.xml_path.should eql "#{xml_dir}/test1_8h.xml"
				v.name.should eql (klass_syms[k] || struct_syms[k])
			}

		end
				
		it "should correctly create template classes" do
			template_class = Doxyparser::parse_class('MyNamespace::TemplateClass', xml_dir)
			params = template_class.template_params
			params.size.should eql 2
			params.each {|param|
				param.class.should eql Doxyparser::Param				
				param.type.class.should eql Doxyparser::Type
			}
			params[0].declname.should eql 'TYPE'
			params[1].declname.should eql 'entero'
			params[0].type.name.should eql 'MyNamespace::TemplateClass::typename'
			params[1].type.name.should eql 'MyNamespace::TemplateClass::int'
			params[0].type.basename.should eql 'typename'
			params[1].type.basename.should eql 'int'
		end
	end

	context "Basic - Members" do

		before(:all) do
			@class=Doxyparser::parse_class("MyNamespace::MyClass", xml_dir)
		end

		it "should correctly create inner classes and structs" do
			innerstruct = @class.innerstructs
			innerclass = @class.innerclasses
			innerstruct.size.should eql 1
			innerclass.size.should eql 1
			innerstruct= innerstruct[0]
			innerclass= innerclass[0]

			innerstruct.class.should eql Doxyparser::Struct
			innerclass.class.should eql Doxyparser::Class
			innerclass.parent.should eql @class
			innerclass.xml_path.should eql xml_dir+"/#{innerclass.refid}.xml"
			innerclass.name.should be_start_with("#{@class.name}::")
		end

		it "should correctly create methods " do			
			expected_methods=['MyClass', 'virtualMethod', 'method', 'isBoolProp', 'getProp', 'setProp', 'operator-', '~MyClass']
			methods = @class.methods
			compare_members methods, expected_methods
		end
		
		it "should correctly create static methods " do			
			expected_methods=['publicStaticMethod', 'getStaticProp', 'setStaticProp']
			methods = @class.methods(:public, :static)
			compare_members methods, expected_methods
		end
		
		it "should correctly create private methods " do			
			expected_methods=['privateMethod1', 'privateMethod2']
			methods = @class.methods(:private)
			compare_members methods, expected_methods
		end
		
		it "should correctly create private static methods " do			
			expected_methods=['privateStaticMethod']
			methods = @class.methods(:private, :static)
			compare_members methods, expected_methods
		end
		
		it "should correctly create protected methods " do			
			expected_methods=['protectedMethod1', 'protectedMethod2']
			methods = @class.methods(:protected)
			compare_members methods, expected_methods
		end
		
		it "should correctly create static attributes " do			
			expected_attributes=['publicStaticField1']
			attributes = @class.attributes(:public, :static)
			compare_members attributes, expected_attributes, Doxyparser::Variable
		end
		
		it "should correctly create private attributes " do			
			expected_attributes=['privateField1', 'privateField2']
			attributes = @class.attributes(:private)
			compare_members attributes, expected_attributes, Doxyparser::Variable
		end
		
		it "should correctly create public enums " do			
			expected_enums=['_Enum', 'InnerEnum']
			enums = @class.innerenums
			compare_members enums, expected_enums, Doxyparser::Enum
		end
		
		it "should correctly create public typedefs " do			
			expected_typedefs=['VectorMapShortVectorInt', 'MapShortVectorInt']
			typedefs = @class.typedefs :public
			compare_members typedefs, expected_typedefs, Doxyparser::Typedef
		end
		
		it "should correctly create private typedefs " do			
			expected_typedefs=['vectorMyClass']
			typedefs = @class.typedefs :private
			compare_members typedefs, expected_typedefs, Doxyparser::Typedef
		end
		
		it "should correctly create friends" do			
			expected_friends=['operator*', 'MyNamespace::friendMethod', 'OuterStruct']
			friends = @class.friends
			compare_members friends, expected_friends, Doxyparser::Friend
			friend_classes = friends.select{|f| f.is_class?}
			friend_classes.size.should eql 1
			'OuterStruct'.should eql friend_classes[0].basename
			qualified_friends = friends.select{|f| f.is_qualified?}
			qualified_friends.size.should eql 1
			'MyNamespace::friendMethod'.should eql qualified_friends[0].basename
		end
	end
end