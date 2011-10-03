Action Plan Service
===================
The Action Plan Service oversee all format action plans.  It gives out format transformation identifier on a 
given PREMIS document describing the characteristic of a file, and render the format action plan as requested.
The format transformation identifier is then passed to DAITSS Transformation Service to carry out the format transformation.  

A format action plan spec out the format specific preservation strategies such as migration and normalization for an institution.
Each format action plan is implemented as an XML document optionally with embedded processing instructions.  The embedded processing 
instructions defines the format transformation identifier on a given format, hence making the action plan “actionable”.   
For example, AVI format action plan may dictate that avi files with various audio and video encodings will be normalized into an 
avi file with Motion JPEG video and PCM audio encoding.  The AVI format action plan would be embedded with a processing instruction like this,

	<normalization>
  		Yes
  		<transformation id="avi_norm"/>
	</normalization>

to normalize avi files according to the defined "avi_norm" transformation identifier.  The avi_norm shall be 
a defined transformation in the DAITSS Transformation Service to carry out the actual format transformation.


Requirements
------------
* ruby (tested on 1.8.6 and 1.8.7)
* ruby-devel, rubygems and git 
* bundler gem (http://gembundler.com/)
* rspec gem (http://rspec.info/)
* sinatra gem - a minimal web server agnostic application framework. It will work with any web server such as mongrel, thin, etc.
  The action plan service has been tested successfully on thin and apache.


Quickstart
----------
1. Retrieve a copy of the action plan service.  You can either create a local git clone of the action plan service, ex.
% git clone https://github.com/daitss/actionplan
or download a copy from the download page.

2. Install all the required gems according to the Gemfile in this project.  It is suggested to use the --path command line variable to install the gems inside the bundle directory
% bundle install --path bundle

3. Add lib/ path to RUBYLIB environment variable
% export RUBYLIB=lib:$RUBYLIB

4. Test the installation via the test harness. 
%spec spec/

5. Run the action plan service with thin (use "thin --help" to get additional information on using thin)
% bundle exec thin start


License
-------
GNU General Public License


Directory Structure
-------------------
* spec: action plan service use rspec for its test harness.  This directory contains the spec files for testing purpose.
* lib: ruby source code
* public: files for public access.  It has the following sub directories,
  * plan: This directory contains the action plans that will be used to determine the preservation strategy during ingest/dissemination.
  * dtd: contain the schema used to ensure the validity of the action plan
  * xsl: stylesheet to render the action plans in html
* views: haml templates.  The premis haml template is used to create premis output for the result of the action plan service.


Usage
-----
For every /migration /normalization /xmlresolution post request with a form parameter description being a PREMIS file object XML,
the action plan service will

* 1. parse the PREMIS xml to extract the format and any codecs
* 2. find an action plan that has a policy for that format/codecs
* 3. if policy dictates transformation -> return status 303 with location field set to the URL of a transformation
* 4. if policy dictates xmlresolution -> return status Non-Error Status
	 otherwise -> return 404 because a preservation action is not found
	
Example:

* HTTP POST request to get the normalization identifier for the object described the file 'premis.xml' where the
  premis.xml is the output from the description service, see http://description.fcla.edu/.  If there is no
  normalization identifier defined for the format described in the premis.xml, action plan service will return 404 not found. 
  
curl -d "object=`cat premis.xml`&event-id-type=URL&event-id-value=info:fda/event/1" http://actionplan.fda.edu/normalization

* HTTP POST request to get the migration identifier for the object described the file 'premis.xml' where the
  premis.xml is the output from the description service, see http://description.fcla.edu/.  If there is no
  migration identifier defined for the format described in the premis.xml, action plan service will return 404 not found.
  
curl -d "object=`cat premis.xml`&event-id-type=URL&event-id-value=info:fda/event/1" http://actionplan.fda.edu/migration