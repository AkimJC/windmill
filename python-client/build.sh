#!/bin/bash
set -e

mkdir openapi
cp  ../backend/windmill-api/openapi.yaml openapi/openapi.yaml

npx @redocly/openapi-cli@latest bundle openapi/openapi.yaml > openapi-bundled.yaml

sed -z 's/FlowModuleValue:/FlowModuleValue2:/' openapi-bundled.yaml  > openapi-decycled.yaml
echo "    FlowModuleValue: {}" >> openapi-decycled.yaml
npx @redocly/openapi-cli@latest bundle openapi-decycled.yaml --ext json -d > openapi-deref.json

sed '$d' .gitignore > .gitignore2
mv .gitignore2 .gitignore

rm -rf windmill-api/ || true
openapi-python-client generate --config $PWD/python-gen.yaml --path openapi-deref.json
rm -rf openapi/
rm openapi*

cp LICENSE windmill-api/
sed -i '5 i license = "Apache-2.0"' windmill-api/pyproject.toml

sed -i 's/authors = \[\]/authors = \["Ruben Fiszel <ruben@windmill.dev>"\]/g' windmill-api/pyproject.toml

echo "# Autogenerated Windmill OpenApi Client" >> windmill-api/README.md.tmp
echo "This is the raw autogenerated api client. You are most likely more interested \
in [wmill](https://pypi.org/project/wmill/) which leverages this client to offer an \
user friendly experience. We use \
[this openapi python client generator](https://github.com/openapi-generators/openapi-python-client/)"\
>> windmill-api/README.md.tmp

echo "" >> windmill-api/README.md.tmp


head -n -13 windmill-api/README.md >> windmill-api/README.md.tmp
mv windmill-api/README.md.tmp windmill-api/README.md

cd windmill-api && poetry build
cd ../wmill && poetry build
cd ../wmill_pg && poetry build
cd .. && echo "windmill-api/" >> .gitignore 