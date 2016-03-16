include wget

class sample_text_data {
    wget::fetch {"sample_text_data":
        timeout  => 0,
        destination => "/texts/sample_journals.zip",
        source  => "http://benschmidt.org/sample_journals.zip",
    }
    ->
      exec { 'unzip texts':
      cwd         => '/texts',
      command     => '/usr/bin/unzip sample_journals.zip',
      user        => 'root',
      refreshonly => true,
    }
}

class sample_image_data {
    wget::fetch {"sample_image_data":
        timeout  => 0,
        destination => "/images/xray.zip",
        source  => "http://www.miriamposner.com/files/xray.zip",
    }
     ->
      exec { 'unzip images':
      cwd         => '/images',
      command     => '/usr/bin/unzip xray.zip',
      user        => 'root',
      refreshonly => true,
      }	      
}

include sample_text_data
include sample_image_data

