#!/bin/bash

set -xe

project_root=$(pwd)
echo "${project_root}"
po_dest="${project_root}/locale/ru/LC_MESSAGES"
cartridge_root="${project_root}/modules/cartridge"
cartridge_rst_src="${project_root}/modules/cartridge/build.luarocks/build.rst"
cartridge_rst_dest="${project_root}/doc/book/cartridge"
cartridge_pot_src="${project_root}/modules/cartridge/build.luarocks/build.rst/locale"
cartridge_pot_dest="${project_root}/locale/book/cartridge"
cartridge_po_src="${project_root}/modules/cartridge/build.luarocks/build.rst/locale/ru/LC_MESSAGES"
cartridge_po_dest="${po_dest}/book/cartridge"
cartridge_cli_root="${project_root}/modules/cartridge-cli/doc"
cartridge_cli_dest="${cartridge_rst_dest}/cartridge_cli"
cartridge_cli_po_dest="${po_dest}/book/cartridge/cartridge_cli"
monitoring_root="${project_root}/modules/metrics/doc/monitoring"
monitoring_dest="${project_root}/doc/book"
monitoring_grafana_root="${project_root}/modules/grafana-dashboard/doc/monitoring"
luatest_root="${project_root}/modules/luatest"
luatest_dest="${project_root}/doc/reference/reference_rock/luatest"

cartridge_kubernetes_root="${project_root}/modules/tarantool-operator/doc/cartridge_kubernetes_guide"
cartridge_kubernetes_dest="${cartridge_rst_dest}/"

tntcxx_root="${project_root}/modules/tntcxx"
tntcxx_gs_dest="${project_root}/doc/getting_started"
tntcxx_api_dest="${project_root}/doc/book/connectors"

cp README.rst doc/contributing/docs/_includes/README.rst

mkdir -p "${luatest_dest}/_includes/"
cd "${luatest_root}"
ldoc --ext=rst --dir=rst --toctree="API" .
cd "${luatest_dest}"
yes | cp -fa "${luatest_root}/rst/." "${luatest_dest}"
yes | cp "${luatest_root}/README.rst" "${luatest_dest}"
yes | mv -f "${luatest_dest}/index.rst" "${luatest_dest}/_includes/"

mkdir -p "${monitoring_dest}"
yes | cp -rf "${monitoring_root}" "${monitoring_dest}/"
yes | cp -rf "${monitoring_grafana_root}" "${monitoring_dest}/"

mkdir -p "${cartridge_cli_dest}" "${cartridge_cli_po_dest}"
cd ${cartridge_cli_root} || exit
find . -iregex '.*\.\(rst\|png\|puml\|svg\)$' -exec cp -rv --parents {} "${cartridge_cli_dest}" \;
cd "${cartridge_cli_root}/locale/ru/LC_MESSAGES/doc/" || exit
find . -name '*.po' -exec cp -rv --parents {} "${cartridge_cli_po_dest}" \;

mkdir -p "${cartridge_kubernetes_dest}"
yes | cp -rf "${cartridge_kubernetes_root}" "${cartridge_kubernetes_dest}"

mkdir -p "${tntcxx_api_dest}/cxx/"
mkdir -p "${tntcxx_gs_dest}/_includes"
yes | cp -rf "${tntcxx_root}/doc/tntcxx_getting_started.rst" "${tntcxx_gs_dest}/getting_started_cxx.rst"
yes | cp -rf "${tntcxx_root}/examples/" "${tntcxx_gs_dest}/_includes/examples/"
yes | cp -rf "${tntcxx_root}/doc/tntcxx_api.rst" "${tntcxx_api_dest}/cxx/"

cd "${cartridge_root}" || exit
CMAKE_DUMMY_WEBUI=true tarantoolctl rocks make

cd "${cartridge_rst_src}" || exit
mkdir -p "${cartridge_rst_dest}"
find . -iregex '.*\.\(rst\|png\|puml\|svg\)$' -exec cp -r --parents {} "${cartridge_rst_dest}" \;

cd "${cartridge_pot_src}" || exit
mkdir -p "${cartridge_pot_dest}"
find . -name '*.pot' -exec cp -r --parents {} "${cartridge_pot_dest}" \;

cd "${cartridge_po_src}" || exit
mkdir -p "${cartridge_po_dest}"
find . -name '*.po' -exec cp -r --parents {} "${cartridge_po_dest}" \;

sed -i -e '/Cartridge CLI<cartridge_cli\/index>/a\' -e '\ \ \ Cartridge Kubernetes guide<cartridge_kubernetes_guide/index>' "${cartridge_rst_dest}/index.rst"
