/*
 * Copyright (c) 2005, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package sandy.util;

import Xml;
import flash.xml.XMLNode;
import flash.xml.XMLDocument;
import flash.xml.XMLNodeType;

import sandy.HaxeTypes;

class FlashXml__ {
	public static var Element(getElement,null) : XmlType;
	public static var PCData(getPCData,null) : XmlType;
	public static var CData(getCData,null) : XmlType;
	public static var Comment(getComment,null) : XmlType;
	public static var DocType(getDocType,null) : XmlType;
	public static var Prolog(getProlog,null) : XmlType;
	public static var Document(getDocument,null) : XmlType;

	public var nodeType(getNodeType,null) : XmlType;
	public var nodeName(getNodeName,setNodeName) : String;
	public var nodeValue(getNodeValue,setNodeValue) : String;
	public var parent(getParent,null) : FlashXml__;

	private var _node : flash.xml.XMLNode;

	public static function parse( str : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLDocument(str);
                return r;
	}

	private function new(){
	}

	public static function createElement( name : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLNode(XMLNodeType.ELEMENT_NODE, name);
		return r;
	}

	public static function createPCData( data : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new XMLNode(XMLNodeType.TEXT_NODE, data);
		return r;
	}

	public static function createCData( data : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLNode(XMLNodeType.CDATA_NODE, data);
		return r;
	}

	public static function createComment( data : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLNode(XMLNodeType.COMMENT_NODE, data);
		return r;
	}

	public static function createDocType( data : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLNode(XMLNodeType.DOCUMENT_TYPE_NODE, data);
		return r;
	}

	public static function createProlog( data : String ) : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLNode(XMLNodeType.PROCESSING_INSTRUCTION_NODE, "xml "+data+"?");
		return r;
	}

	public static function createDocument() : FlashXml__ {
		var r = new FlashXml__();
		r._node = new flash.xml.XMLDocument();
		return r;
	}

	private static function getElement() : XmlType
	{
		return Xml.Element;
	}

	private static function getPCData() : XmlType
	{
		return Xml.PCData;
	}

	private static function getCData() : XmlType
	{
		return Xml.CData;
	}

	private static function getComment() : XmlType
	{
		return Xml.Comment;
	}

	private static function getDocType() : XmlType
	{
		return Xml.DocType;
	}

	private static function getProlog() : XmlType
	{
		return Xml.Prolog;
	}

	private static function getDocument() : XmlType {
		return Xml.Document;
	}

        private function getNodeType() : XmlType {
		switch (_node.nodeType)
		{
		case XMLNodeType.ELEMENT_NODE :  // 1
			return Xml.Element;
		case XMLNodeType.TEXT_NODE : // 3
			return Xml.PCData;
//		case XMLNodeType.XMLNodeType.CDATA_NODE : // 4
//			return Xml.CData;
		case XMLNodeType.PROCESSING_INSTRUCTION_NODE : // 7
			return Xml.Prolog;
		case XMLNodeType.COMMENT_NODE : // 8
			return Xml.Comment;
//		case XMLNodeType.DOCUMENT_NODE : // 9
//			return Xml.Document;
		case XMLNodeType.DOCUMENT_TYPE_NODE : // 10
			return Xml.DocType;
		default :
			throw "unimplemented node type: " + _node.nodeType;
		}
		return null;
	}

	private function getNodeName() : String {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		return _node.nodeName;
	}

	private function setNodeName( n : String ) : String {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		_node.nodeName = n;
		return n;
	}

	private function getNodeValue() : String {
		if( _node.nodeType == XMLNodeType.ELEMENT_NODE /*|| _node.nodeType == DOCUMENT_NODE*/ )
			throw "bad nodeType";
		return _node.nodeValue;
	}

	private function setNodeValue( v : String ) : String {
		if( _node.nodeType == XMLNodeType.ELEMENT_NODE /*|| _node.nodeType == DOCUMENT_NODE*/ )
			throw "bad nodeType";
		return _node.nodeValue = v;
	}

	private function getParent() {
		var r = new FlashXml__();
		r._node = _node.parentNode;
		return r;
	}

	public function get( att : String ) : String {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		return Reflect.field(_node.attributes, att);
	}

	public function set( att : String, value : String ) : Void {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		Reflect.setField(_node.attributes, att, value);
	}

	public function remove( att : String ) : Void{
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		Reflect.deleteField(_node.attributes, att);
	}

	public function exists( att : String ) : Bool {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
		var attributes = _node.attributes;
		return Reflect.hasField(attributes, att);
	}

	public function attributes() : Iterator<String> {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE )
			throw "bad nodeType";
                
		return Reflect.fields(_node.attributes).iterator();
	}

	public function iterator() : Iterator<FlashXml__> {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var children = _node.childNodes;
		var cur = 0;
		return {
			hasNext : function(){
				return cur < children.length;
			},
			next : function(){
				var r = new FlashXml__();
				r._node = children[cur++];
				return r;
			}
		}
	}

	public function elements() : Iterator<FlashXml__> {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var children = _node.childNodes;
		var cur = 0;
                var elements:Array<XMLNode> = new Array();
		for (node in children){
			if (node.nodeType == XMLNodeType.ELEMENT_NODE)
				elements.push(node);
		}
		children = null;
		return {
			hasNext : function(){
				return cur < elements.length;
			},
			next : function(){
				var r = new FlashXml__();
				r._node = elements[cur++];
				return r;
			}
		}
	}

	public function elementsNamed( name : String ) {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var children = _node.childNodes;
		var cur = 0;
                var elements:Array<XMLNode> = new Array();
		for (node in children){
			if (node.nodeType == XMLNodeType.ELEMENT_NODE && node.nodeName == name)
				elements.push(node);
		}
		children = null;
		return {
			hasNext : function(){
				return cur < elements.length;
			},
			next : function(){
				var r = new FlashXml__();
				r._node = elements[cur++];
				return r;
			}
		}
	}

	public function firstChild() : FlashXml__ {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var r = new FlashXml__();
		r._node = _node.firstChild;
		return r;
	}

	public function firstElement() : FlashXml__ {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var node = _node.firstChild;
		while (node != null) {
			if (node.nodeType == XMLNodeType.ELEMENT_NODE) {
				var r = new FlashXml__();
				r._node = node;
				return r;
			}
			node = node.nextSibling;
		}
		return null;
	}

	public function addChild( x : FlashXml__ ) : Void {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		_node.appendChild(x._node);
	}

	public function removeChild( x : FlashXml__ ) : Bool {
		if (x._node.parentNode != _node)
			return false;
		x._node.removeNode();
		return true;
	}

	public function insertChild( x : FlashXml__, pos : Int ) : Void {
		if( _node.nodeType != XMLNodeType.ELEMENT_NODE /*&& _node.nodeType != XMLNodeType.DOCUMENT_NODE*/)
			throw "bad nodetype";
		var children = _node.childNodes;
		if ( children.length < pos )
			_node.appendChild(x._node);
		_node.insertBefore( x._node, children[pos] );
	}

	public function toString() {
		//return _node.toString();
		return nodeToString(_node);
	}

	private function nodeToString(node:XMLNode):String {
		switch (node.nodeType) {
		case XMLNodeType.ELEMENT_NODE:
			if (node.nodeName == null)
				return childrenToString(node);
			if (node.childNodes.length > 0) {
				return "<"+node.nodeName+
					attrsToString(node)+">"+
					childrenToString(node)+
					"</"+node.nodeName+">";
			} else {
				return "<"+node.nodeName+
					attrsToString(node)+"/>";
			}
//		case XMLNodeType.ATTRIBUTE_NODE:
		case XMLNodeType.TEXT_NODE:
			return node.nodeValue;
		case XMLNodeType.CDATA_NODE:
			return "<![CDATA "+node.nodeValue+" ]]>";
//		case XMLNodeType.ENTITY_REFERENCE_NODE:  // FIX ME
//		case XMLNodeType.ENTITY_NODE: // FIX ME
		case XMLNodeType.PROCESSING_INSTRUCTION_NODE:
			return "<?"+node.nodeValue+">\n";
		case XMLNodeType.COMMENT_NODE:
			return "<!-- "+node.nodeValue+" -->";
//		case XMLNodeType.DOCUMENT_NODE:
//			return childrenToString(node);
		case XMLNodeType.DOCUMENT_TYPE_NODE:
			return "<!DOCTYPE "+node.nodeValue+" >";
//		case XMLNodeType.DOCUMENT_FRAGMENT_NODE: // FIX ME
//		case XMLNodeType.NOTATION_NODE: // FIX ME
		}
		return "";
	}

	private function attrsToString(node:XMLNode):String {
		var s = "";
		var attributes = node.attributes;
		for (att in Reflect.fields(attributes)) s += " " + att +
			"=\""+Reflect.field(attributes, att)+"\"";
		return s;
	}

	private function childrenToString(node:XMLNode):String {
		var nodes = node.childNodes;
		var s = "";
		for (node in nodes) s+= nodeToString(node);
		return s;
	}
}
