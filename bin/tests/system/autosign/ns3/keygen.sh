#!/bin/sh -e

# Copyright (C) Internet Systems Consortium, Inc. ("ISC")
#
# SPDX-License-Identifier: MPL-2.0
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0.  If a copy of the MPL was not distributed with this
# file, you can obtain one at https://mozilla.org/MPL/2.0/.
#
# See the COPYRIGHT file distributed with this work for additional
# information regarding copyright ownership.

. ../../conf.sh

SYSTESTDIR=autosign

dumpit() {
  echo_d "${debug}: dumping ${1}"
  cat "${1}" | cat_d
}

setup() {
  echo_i "setting up zone: $1"
  debug="$1"
  zone="$1"
  zonefile="${zone}.db"
  infile="${zonefile}.in"
  n=$((${n:-0} + 1))
}

mkdir inactive

setup secure.example
cp $infile $zonefile
ksk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  NSEC3/NSEC test zone
#
setup secure.nsec3.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  NSEC3/NSEC3 test zone
#
setup nsec3.nsec3.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  Jitter/NSEC3 test zone
#
setup jitter.nsec3.example
cp $infile $zonefile
count=1
while [ $count -le 1000 ]; do
  echo "label${count} IN TXT label${count}" >>$zonefile
  count=$((count + 1))
done
# Don't create keys just yet, because the scenario we want to test
# is an unsigned zone that has a NSEC3PARAM record added with
# dynamic update before the keys are generated.

#
#  OPTOUT/NSEC3 test zone
#
setup optout.nsec3.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A nsec3 zone (non-optout).
#
setup nsec3.example
cat $infile dsset-*.${zone}. >$zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# An NSEC3 zone, with NSEC3 parameters set prior to signing
#
setup autonsec3.example
cat $infile >$zonefile
ksk=$($KEYGEN -G -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
echo $ksk >../autoksk.key
zsk=$($KEYGEN -G -q -a $DEFAULT_ALGORITHM -3 $zone 2>kg.out) || dumpit kg.out
echo $zsk >../autozsk.key
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  OPTOUT/NSEC test zone
#
setup secure.optout.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  OPTOUT/NSEC3 test zone
#
setup nsec3.optout.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
#  OPTOUT/OPTOUT test zone
#
setup optout.optout.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A optout nsec3 zone.
#
setup optout.example
cat $infile dsset-*.${zone}. >$zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A RSASHA256 zone.
#
setup rsasha256.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a RSASHA256 -b 2048 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a RSASHA256 -b 2048 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A RSASHA512 zone.
#
setup rsasha512.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a RSASHA512 -b 2048 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a RSASHA512 -b 2048 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# NSEC-only zone. A zone using NSEC-only DNSSEC algorithms.
# None of these algorithms are supported for signing in FIPS mode
# as they are MD5 and SHA1 based.
#
if (
  cd ..
  $SHELL ../testcrypto.sh -q RSASHA1
); then
  setup nsec-only.example
  cp $infile $zonefile
  ksk=$($KEYGEN -q -a RSASHA1 -fk $zone 2>kg.out) || dumpit kg.out
  $KEYGEN -q -a RSASHA1 $zone >kg.out 2>&1 || dumpit kg.out
  $DSFROMKEY $ksk.key >dsset-${zone}.
else
  echo_i "skip: nsec-only.example - signing with RSASHA1 not supported"
fi

#
# Signature refresh test zone.  Signatures are set to expire long
# in the past; they should be updated by autosign.
#
setup oldsigs.example
cp $infile $zonefile
count=1
while [ $count -le 1000 ]; do
  echo "label${count} IN TXT label${count}" >>$zonefile
  count=$((count + 1))
done
$KEYGEN -q -a $DEFAULT_ALGORITHM -fk $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM $zone >kg.out 2>&1 || dumpit kg.out
$SIGNER -PS -x -s now-1y -e now-6mo -o $zone -f $zonefile.signed $zonefile >s.out || dumpit s.out
cp $zonefile.signed $zonefile.bak
mv $zonefile.signed $zonefile

#
# NSEC3->NSEC transition test zone.
#
setup nsec3-to-nsec.example
$KEYGEN -q -a $DEFAULT_ALGORITHM -fk $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM $zone >kg.out 2>&1 || dumpit kg.out
$SIGNER -S -3 beef -A -o $zone -f $zonefile $infile >s.out || dumpit s.out

#
# Introducing a pre-published key test.
#
setup prepub.example
infile="prepub.example.db.in"
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk $zone >kg.out 2>&1 || dumpit kg.out
zsk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone 2>kg.out) || dumpit kg.out
echo $zsk >../prepub.key
$SIGNER -S -3 beef -o $zone -f $zonefile $infile >s.out || dumpit s.out

#
# Key TTL tests.
#

# no default key TTL; DNSKEY should get SOA TTL
setup ttl1.example
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone >kg.out 2>&1 || dumpit kg.out
cp $infile $zonefile

# default key TTL should be used
setup ttl2.example
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk -L 60 $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -L 60 $zone >kg.out 2>&1 || dumpit kg.out
cp $infile $zonefile

# mismatched key TTLs, should use shortest
setup ttl3.example
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk -L 30 $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -L 60 $zone >kg.out 2>&1 || dumpit kg.out
cp $infile $zonefile

# existing DNSKEY RRset, should retain TTL
setup ttl4.example
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -L 30 -fk $zone >kg.out 2>&1 || dumpit kg.out
cat ${infile} K${zone}.+*.key >$zonefile
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -L 180 $zone >kg.out 2>&1 || dumpit kg.out

#
# A zone with a DNSKEY RRset that is published before it's activated
#
setup delay.example
ksk=$($KEYGEN -G -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
echo $ksk >../delayksk.key
zsk=$($KEYGEN -G -q -a $DEFAULT_ALGORITHM -3 $zone 2>kg.out) || dumpit kg.out
echo $zsk >../delayzsk.key
cp delay.example.db.in delay.example.db

#
# A zone with signatures that are already expired, and the private KSK
# is missing.
#
setup noksk.example
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
zsk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone 2>kg.out) || dumpit kg.out
$SIGNER -S -P -s now-1mo -e now-1mi -o $zone -f $zonefile ${zonefile}.in >s.out || dumpit s.out
echo $ksk >../noksk-ksk.key
rm -f ${ksk}.private

#
# A zone with signatures that are already expired, and the private ZSK
# is missing.
#
setup nozsk.example
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
zsk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone 2>kg.out) || dumpit kg.out
$SIGNER -S -P -s now-1mo -e now-1mi -o $zone -f $zonefile ${zonefile}.in >s.out || dumpit s.out
echo $ksk >../nozsk-ksk.key
echo $zsk >../nozsk-zsk.key
rm -f ${zsk}.private

#
# A zone with signatures that are already expired, and the private ZSK
# is inactive.
#
setup inaczsk.example
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
zsk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone 2>kg.out) || dumpit kg.out
$SIGNER -S -P -s now-1mo -e now-1mi -o $zone -f $zonefile ${zonefile}.in >s.out || dumpit s.out
echo $ksk >../inaczsk-ksk.key
echo $zsk >../inaczsk-zsk.key
$SETTIME -I now $zsk >st.out 2>&1 || dumpit st.out

#
# A zone that is set to 'dnssec-policy' during a reconfig
#
setup reconf.example
cp secure.example.db.in $zonefile
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone >kg.out 2>&1 || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out

#
# A zone which generates CDS and CDNSEY RRsets automatically (with an additional CSK)
#
setup sync.example
cp $infile $zonefile
ksk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk -P sync now $zone 2>kg.out) || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.
echo ns3/$ksk >../sync.key

#
# A zone that generates CDS and CDNSKEY automatically
#
setup kskonly.example
cp $infile $zonefile
ksk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk -P sync now $zone 2>kg.out) || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A zone that has a published inactive key that is autosigned.
#
setup inaczsk2.example
cp $infile $zonefile
ksk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q -P now -A now+3600 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.

#
# A zone that starts with an active KSK + ZSK and an inactive ZSK, with the
# latter getting deleted during the test.
#
setup delzsk.example
cp $infile $zonefile
ksk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -a $DEFAULT_ALGORITHM -3 -q $zone >kg.out 2>&1 || dumpit kg.out
zsk=$($KEYGEN -a $DEFAULT_ALGORITHM -3 -q -I now-1w $zone 2>kg.out) || dumpit kg.out
cat $zsk.key >>$zonefile
mv $zsk.key inactive/
mv $zsk.private inactive/
echo $zsk >../delzsk.key

#
# Check that NSEC3 are correctly signed and returned from below a DNAME
#
setup dname-at-apex-nsec3.example
cp $infile $zonefile
ksk=$($KEYGEN -q -a $DEFAULT_ALGORITHM -3 -fk $zone 2>kg.out) || dumpit kg.out
$KEYGEN -q -a $DEFAULT_ALGORITHM -3 $zone >kg.out 2>&1 || dumpit kg.out
$DSFROMKEY $ksk.key >dsset-${zone}.
