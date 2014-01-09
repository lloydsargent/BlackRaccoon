
Pod::Spec.new do |s|
  s.name         = "BlackRaccoon"
  s.version      = "1.0"
  s.summary      = "IOS FTP Client Code"

  s.description  = "BlackRaccoon is a collection of routines used to act as an FTP client."

  s.homepage     = "https://github.com/lloydsargent/BlackRaccoon"

  s.license      = { :type =>'ARC', :file=> 'LICENSE.txt'}
  s.authors       = { "Lloyd Sargent" => "lloyd.sargent@cannasoftware.com", "Valentin Radu" => "radu.v.valentin@gmail.com" }

  s.source       = { :git => "https://github.com/lloydsargent/BlackRaccoon.git", :tag => "1.0" }

  s.source_files  = 'BlackRaccoon/BlackRaccoon/*.{h,m}'

  s.framework  = 'CFNetwork'

end
