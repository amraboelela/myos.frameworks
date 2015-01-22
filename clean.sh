#
# Copyright © 2014 myOS Group.
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

echo
echo "****************************** Cleaning frameworks ******************************"

#cd CoreFoundation
#make clean
#cd ..

cd Foundation
make clean
cd ..

cd CoreGraphics
make clean
cd ..

cd CoreText
make clean
cd ..

cd IOKit
make clean
cd ..

cd OpenGLES
make clean
cd ..

cd CoreAnimation
make clean
cd ..

cd UIKit
make clean
cd ..
