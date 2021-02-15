#!/bin/bash

wrap() {
  echo
  echo $1
  shift
  echo "> $@"
  echo
  $@
}


#xmlstarlet val -e FightClub5eXML/Sources/*.xml
xmlstarlet val -e Collections/*.xml
xmlstarlet val -e -s Utilities/collection.xsd Collections/*.xml
#xmlstarlet val -e -s Utilities/compendium.xsd FightClub5eXML/Sources/*.xml

xmlstarlet val -e UVMS-Campaign/*.xml
xmlstarlet val -e -s Utilities/compendium.xsd UVMS-Campaign/*.xml

LIST=Collections/UVMS-Campaign.xml

for i in $LIST; do
    # wrap "Merge FightClub5eXML/$i" \
    # xsltproc -o FightClub5eXML/$i Utilities/merge.xslt $i;

    wrap "Merge FightClub5eXML/${i%.*}-filter.xml" \
    xsltproc -o FightClub5eXML/${i%.*}-filter.xml Utilities/filterMerge.xslt $i;
done

echo "Validate"
xmlstarlet val -e -s Utilities/compendium.xsd FightClub5eXML/Collections/UVMS-Campaign.xml

# Find Eldritch Knight eligible spells
# xmlstarlet sel -T -t -m '/compendium/spell[school = "A" or school = "EV"]' -v "name" -o " - " -v "school" -o ", " -v "classes" -n FightClub5eXML/Collections/UVMS-Campaign-filter.xml | grep Wizard | grep -v Eldritch

# Find Arcane Trickster eligible spells
# xmlstarlet sel -T -t -m '/compendium/spell[school = "EN" or school = "I"]' -v "name" -o " - " -v "school" -o ", " -v "classes" -n FightClub5eXML/Collections/UVMS-Campaign-filter.xml | grep Wizard | grep -v Rogue

# Find Wizard Ritual spells (for ritual caster)
# xmlstarlet sel -T -t -m '/compendium/spell[ritual = "YES"]' -v "name" -o " - " -v "school" -o ", " -v "classes" -n FightClub5eXML/Collections/UVMS-Campaign-filter.xml | grep Wizard | grep -v Ritual
