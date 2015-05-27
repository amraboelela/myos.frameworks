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
myosclean
cd ..

cd CoreFoundation
myosclean
cd ..

cd CoreGraphics
myosclean
cd ..

cd CoreText
myosclean
cd ..

cd IOKit
myosclean
cd ..

cd OpenGLES
myosclean
cd ..

cd QuartzCore
myosclean
cd ..

cd UIKit
myosclean
cd ..
