name             'iisposh'
maintainer       'Darrell Johnson'
maintainer_email 'darrellj@ebsco.com'
license          'All rights reserved'
description      'Installs/Configures IIS Features'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '2.2.7'

depends		'windows_feature', '~>1.0'
source_url 'https://github.com/ebsco/iisposh' if respond_to?(:source_url)