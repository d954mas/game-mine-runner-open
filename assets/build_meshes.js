#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const meshesDir = __dirname + "/meshes";

const number = 10;
//https://jsstringconverter.bbody.io/
const buffer_content ="[\n" +
	"   {\n" +
	"      \"name\":\"position\",\n" +
	"      \"type\":\"float32\",\n" +
	"      \"count\":3,\n" +
	"      \"data\":[\n" +
	"         -1.0,\n" +
	"         -1.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         -1.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         -1.0,\n" +
	"         -1.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         -1.0,\n" +
	"         1.0,\n" +
	"         0.0\n" +
	"      ]\n" +
	"   },\n" +
	"   {\n" +
	"      \"name\":\"normal\",\n" +
	"      \"type\":\"float32\",\n" +
	"      \"count\":3,\n" +
	"      \"data\":[\n" +
	"         0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         -0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         -0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         -0.0,\n" +
	"         0.0,\n" +
	"         1.0\n" +
	"      ]\n" +
	"   },\n" +
	"   {\n" +
	"      \"name\":\"texcoord0\",\n" +
	"      \"type\":\"float32\",\n" +
	"      \"count\":2,\n" +
	"      \"data\":[\n" +
	"         0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         0.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         0.0,\n" +
	"         1.0\n" +
	"      ]\n" +
	"   },\n" +
	"   {\n" +
	"      \"name\":\"color0\",\n" +
	"      \"type\":\"float32\",\n" +
	"      \"count\":4,\n" +
	"      \"data\":[\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0,\n" +
	"         1.0\n" +
	"      ]\n" +
	"   }\n" +
	"]\n";
	
var mesh_content = "material: \"/assets/materials/mesh.material\"\n" +
	"vertices: \"/assets/meshes/quad.buffer\"\n" +
	"textures: \"/assets/textures/sector.png\"\n" +
	"primitive_type: PRIMITIVE_TRIANGLES\n" +
	"position_stream: \"position\"\n" +
	"normal_stream: \"normal\"\n" +
	"\n";
	
var go_content = "components {\n" +
	"  id: \"mesh\"\n" +
	"  component: \"/assets/meshes/mesh_1.mesh\"\n" +
	"  position {\n" +
	"    x: 0\n" +
	"    y: 0.0\n" +
	"    z: 0\n" +
	"  }\n" +
	"  rotation {\n" +
	"    x: 0.0\n" +
	"    y: 0.0\n" +
	"    z: 0.0\n" +
	"    w: 0.0\n" +
	"  }\n" +
	"}\n" +
	"\n";
	


fs.readdirSync(meshesDir).forEach(f => fs.rmSync(`${meshesDir}/${f}`));

console.log("clear")



for (let i = 1; i <= number; i++) {
	const go_filename = meshesDir + "/mesh_" + i + ".go";
	const buffer_filename = meshesDir + "/mesh_" + i + ".buffer";
	const mesh_filename = meshesDir + "/mesh_" + i + ".mesh";
	//use one buffer for meshes
	//if(i==1){
		fs.writeFileSync(buffer_filename, buffer_content, { encoding: "utf-8" });
	//}
	
			
		let mesh_content_new = mesh_content.replace('/assets/meshes/quad.buffer',
	'/assets/meshes/mesh_' + i + ".buffer"); 
	fs.writeFileSync(mesh_filename, mesh_content_new, { encoding: "utf-8" });
	
	let go_content_new = go_content.replace('/assets/meshes/mesh_1.mesh',
	'/assets/meshes/mesh_' + i + ".mesh"); 
	fs.writeFileSync(go_filename, go_content_new, { encoding: "utf-8" });
	
	 
	
	 
	 console.log("mesh_" + i) 
}

const collection_filename = meshesDir + "/mesh.collection";
var collection_string = "name: \"default\"\n"
var collection_instance_string = "instances {\n" +
	"  id: \"mesh_1\"\n" +
	"  prototype: \"/assets/meshes/mesh_1.go\"\n" +
	"  position {\n" +
	"    x: 0.0\n" +
	"    y: 0.0\n" +
	"    z: 0.0\n" +
	"  }\n" +
	"  rotation {\n" +
	"    x: 0.0\n" +
	"    y: 0.0\n" +
	"    z: 0.0\n" +
	"    w: 1.0\n" +
	"  }\n" +
	"  scale3 {\n" +
	"    x: 1.0\n" +
	"    y: 1.0\n" +
	"    z: 1.0\n" +
	"  }\n" +
	"}\n";
	
for (let i = 1; i <= number; i++) {
	let collection_instance_string_new = collection_instance_string.replaceAll('mesh_1',
	'mesh_' + i);
	collection_string += collection_instance_string_new;
}


collection_string += "scale_along_z: 0"

fs.writeFileSync(collection_filename, collection_string, { encoding: "utf-8" });

console.log("done") 
