#
# Copyright © 2014-2015 myOS Group.
#
# This file is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# Contributor(s):
# Amr Aboelela <amraboelela@gmail.com>
#

#source ${MYOS_PATH}/sdk/config.sh

echo
echo "****************************** Cleaning frameworks ******************************"

cd Foundation
source clean.sh
cd ..

cd CoreFoundation
source clean.sh
cd ..

cd CoreGraphics
source clean.sh
cd ..

cd CoreText
source clean.sh
cd ..

cd IOKit
source clean.sh
cd ..

cd OpenGLES
source clean.sh
cd ..

cd QuartzCore
source clean.sh
cd ..

cd UIKit
source clean.sh
cd ..
