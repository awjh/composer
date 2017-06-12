ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop


# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# Start all Docker containers.
docker-compose -p composer -f docker-compose-playground.yml up -d

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start"

# removing instalation image
rm "${DIR}"/install-hlfv1.sh

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��>Y �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/�����}�s:�n�O��/�i� h�<^Q�D^����cJ"��1��R#?�;����vZ�}Y��v�����(�G�O|?�������4^f2#.�?Et%�2��oK�_��C��_�,��w���叒$Zɿ\(����⊽u6\.��9�%���}��S���p���cQ%�p_����˰3]�?�GS�A'�'�B�c����$M}�u>�?�p'�4��?k�Z�?��i�v1w��<��)��Q��Q�b��q�e����Q��HsmǣHE��o�Ϛ{~�2�Z����c��ǋ��)c �p�u'6d�&�B�z�lC��E�T)M��(�2�I}a,0���F)�[e�ւ6U�	�e���i�ϯ}�`!���x�	Z��Աc���#��sݧ(��h��:���OYz8�l%�n���Ri&������Ł��"�-T?�%�^|��}��:+��K_�������m/�.]?]��1|���Q��_)�(��U\�^'~����������@*�_
�^�Y��Bm�j~Y����\�@(k�R�Y��2C�gͥ�m-��0\M�nO�0�BE�r��,�Դ�����A4��A �<��5L���x�Fdb�P�S�S�&mdq���!9�G��9����'��6̅;g�ヸ��B��b�Mn1�zn���A�!⊠���z�ŌG�!e�^=ܗ� v0?�`����С�C�����������N�����5���r7�6�8Xs�+���n�b.�q�|������[K���
�4���6A(�(:�)( 2�T_#Bi���Ю/滑D���H���`��Ɗ�Q+S��_vЦ�6��0�Y�%C��#�w��f��9�[ݙ��\����� ���=!98�ģȓ�Ơ�/F^ .ԏ���4<��XR����G��H��eQV���I9h�71��oVL�̖�Q��@���Fc$J�Ms�<0
Q� 	�"xY����Ɂ\&�$�H�Kqc6˨�9�v��oX���[NҖ�FSŋYW2Y1��@�E#�3�^<�F�.����lx6���Y~I�g�����G��K���Q�S�U�G��?��X��e�5�g�;���@=2̛흺_���@�8��В��X>̐#q���^B�Џ��
|Hʑ�z E�����de���2s��I���:?�2��4]�!�l��b��p��#v�D���[�NuM1GkH���5q"5q1u{W���~�y캼W�y.�V�v�
�~ ����2t����[���˶:U �U��ք9P�m�0<Z GZoi�rf�m qyQ��+ ���t��k��k��Aȁ3_�A7��}���|Ƿ4�צ����4���I#�9�u �-�5�!��̶��	�4���qG�"j>ob��bM�CAn�{�I���sn
��L�k�t���mfՇJ&�����)~I�����=�O�d�Q
>D�?s�����Gh���T���W���k���sL���O�%T�_~I���C�te���*�������O��$�^@�lqu�"���4e�"����Q~�d�b4�z�W���](C���?�������+����8؏;���p����.��g	}��@���p�����ֲ�۶̈ɸ!'MS�L���-eXO6C����c�}��t�Y�̱�1G[K|���n�,�F	�6Kٞ�U��{�K��3����R�Q�������e���������j��]��3�*�/$�G��S���m�?�{���
���#��fk�/���0�`������F߻58v}&�C\����}@��r���L�1ɤޛJsk:�LІ����CE�ctW$a��:�;^o�a�����5Q�Ǡ)Q/�q�@�:ܠ�ɪc��,�=Ѻ�i[<2.g�cDґ����9��A�6h�p�4�Cr��mEl	`�8�v�vSt���MV&�����-�3�q�|�0�ٓI�28	LE5�xǰW�|h֣�ZLB6ޮ;-�mvZgiϔ��uG=��f�TS�%������d�R$/k7t !s���IV=h��x��_����CU�_>D���S�)��������?�x��w�w� ���Q���\"�Wh�E\��������+��������!���Z� U�_���=�&�p�Q��Ѐ�	�`h׷4�0�u=7pqaX��qa	�gQ�%Iʮ��~?�!������+��\��2aW�W���X�plNl����{���6[�A�z�^��+����q�N+)54$wm'���ǫ{���(ǌ��v��7pD���������=n2�L?�SJN�v�*���x������O����D��_� ����������].����˔����	�Z����Px��e�p��i'+������K�A/�?�bHu����?�>?�IW�?e�S�?K#t�������6�26�R��Q��,��x4B��x���o���FQi(C������1�S�����`�����x�����	���m,� �r�+�5�D�|����j@.�l�uw�9��+>��z*�F��Qc&�:e^3�Z������p�i�a��3���}m�`�`f���ϻ����������J��`��$���������'��՗FU(e���%ȧ���U��P
^��j�<�{��΁X�qе
�%,�!?��<�}t�gI �����7����*-û���֍��{�.���@7�Gy���D���=�Z�a��=
'���N1��+݅��ΈA??$��}�؄q��1r-��f��Ex�p�LNp�ɬ'��x��bs5�9jo�EsI�٠��`�uF9��z��2<�Q&�3b��Cb����k�Cba΅�x|�s�[SW�m��Dk�
?o@���P�r<����T���xl�A�Z�n�yP�:#���6\�����|t{@�	NSΦ�4o���7�ڊlt��H�,�e�S����Ӷ7���{@��p��f�	zR.�do��l��-�U].��x�4������������q���K�oa�Sxe��M��������-Q��_�����$P���^
�v���c��_��n�$��T�wxv�#�����2?yf(?��G�tw��@�O΁@�q[z-PS �]��'n����I>�AB���Nu7%�},mQI�����z�6�}�VzjJ���[3�c�҄�!��fL�9M���Tnx@A����㤯&���A@OB�=��܇.���� ��Y>h��@�Dk�<�w�u7��+e0��j.uq�?%s9��V{f��!Wk����=h�t�0B��G�P��a�?������/�����Gh���+���O>��������X����?e��=���������G��_��W����������\l�cV��s9�\��[w�?F!T�Y
*������?�����z��S��[)���	��i�P��"Y�eh��(�	�	� �]�}�pȀ�� �}�r]�q����V(C���?��B���O)���PZ�d��a�2�f�����9��6ض��"o䑶hQ����hN�m�`]	otw�K��#`����;VaDI�1�ַ����0�k�d=�(G��b(���:�b��W��/v�~Z��(�3�z->�?_�(�ԓ�/�a��/[?�
-����e~���~���\9^j�id����d������b9��N�+���c���B��k��^$������2���Mj���8]�oxp��*�7�_���zu쇟�>���:�~��I|=��SY1q#{�}�e�ڕ[���=jG�kWE��q�"�.�ګO~���F��Fs�}> s^�ʩ�X|=���ծ��l��&���5|IV��o���\�ӥ��,����}sw3�hpk+�Μ���j_�V��.�[]]uQ�i�����MG��
A��o���ϋ��׾�WD���e�ZSI��`�j���y�av}�U��E�g_�l��ߓ�o���7��d�y�,�3�^�����c�u��ڋ��/{lyˤ�>�zqoOW�O����������O�w������[������W�����@.j�=l��SW�8�O��7M���8Y�a���	��.Nד�s]��,�GR��j�h�B"GE��H	����}7A5���~�ȇ3�x�i��NU��c������	d��
�8��!�"v�7�h�<n��#��:����M�X3B�+�Ʒ�r��
��$����N�t��ϖ����{�Ǎ�^{<�Y�m�ڝ�Mk��q��"�_{v�$��j�ՒZ��,EQ%�T��w0��{|��=�CrJ�!@�K�� �A~� A�T��o��=�����ޫW�z��M*��3�B���=���'Xl2�5L��Gn�MY�9i"�@�m �E�)&YlĂ��d6M=Jf��,�m#�j�$�@rya��l&��۬;6�r�4mѣ�)�!�΋L�1���tn��(al�B��z]���$)=hpM�u�?rM4��C%���0VWd#��.* Ă˂���i�a�l����5(�P�K$���|���s�Lb���d6g�ԅ\!��š�ܳJPU�*ב�sڻi;�*�ˈ#�ٶP���yKHN��A�7�2�hk��J|~�y�+��Kc�mA�h���nW���,kJ.���ۚ.�!�[k�̠M�S�,�ti��9]�ӳ�SϜ9�}�)u.s:za�i�`��D�����2;��ݖ�AMU:re�o��>���-�$�͉�<�\E��/r��$�$2��(~�߷���~�q��,���)UAa�����K���}��o��1���A�U��P �Șex�ȂwaW4�O��V�]r�34SyNʢ���Ö`��S���d�8�lQmI8QωFh�sH��JS������3�fy=���J���桹��(h|�X���̻�s�@%�-i��~�AA����C��th!](&h����e<m�U�#h�Af����;�Ѕ��$��_��:=]���"��5ێ`�ש8xU�@T"���O#x�ȳ�������iG���J��?}�N�����=3�㡝���KI�����s���n��Rwd�쬝��r����ٱ�􆑲l�i���.�2'�Ӵ!��Oۤ�*Y���е&{/ྟ�t���t�?\��.%-h]�ԊғI
ZQ���p��^����4�?M{�3�zC���KI��!ʢL�9��u��d#x�#N��9o���srW���� �ڑerGX��	:��w�c R��������;@��pǍ�)���p��"ehS����ć�� �y<�I��	(��ܑ$d�M�Fɠ*B��4rn;�{Ur��$h�n�oW�'��!���$�/YC�� ��9f�<K�����f�7ͻ�ěy�#ZDTOmRT���O�m�nˊ�7����Y$'�C��J%����"E�S&xl�S��!'� r�Wd�$���Q���hX\�#�F&D{E���eT���HI�	�&HpH���"_��s���`>j�n���f���x�@�w�U�@�E5�U��>q܅D��*��c{ ��*u�˪�5���`�M�ܝ�`�ᄾ�[���AE��/�߲N���H�Lu>o�o���-�E���r{��69���/%M����Qyڪ�8_1�UDr��B���l� `8�	��8�7�v���G��E��ڌ|�����fN��^�����Ik��j�c��OU�]���������B��S�� ���t���^7����H���:ژt�B�u���E6�$�%��P�(,��lh�Y[���ϫ��(�53~Kp���"�����u���N�ܖ�c���.�;�������$s�$(tIi�UW�̌�j	�**��f�y�T��H�O��ʕ�	������x]Qଞ@.�>�2�T��w�m�lN�w�Y��53x���	�'�I�D�����:q �f��db��d<efMxMࢆwdM���9M�s�k�t�{�- {)��	KDS��nL�Ģ��yz�9&�{d��ZN��"�I7~[`cU�;sU��}�t�u@sB�p�֯?pn�>ܺa�ʃ��?x��X���w���?|��ӑ���RR?���s��i�Ձ߿I�5��pc��Ɋ��2t
�b��%Z&�i�p̊qLK��Ӊ-��3�:?�ӯ��:��?\NZ����;����G�?���$�n�KI'm��L
�j��=���۽���R���/��`U�qAU�}���Ы3DL��z�m�{��g?����g��X�c �_�d�Rk�����m"�k-�N���-Lo|����0���h�
�/�wpR�?Ϥ�*��Z�?�����k���������>ձ� �\�(^�ta�C4B4W��ђO��'^�ȶ���U�xA�!�1短¨t�z��(��?���gRx��{���_��\��)�����}�2��h��m�N��/�ٍ�㐂#��˓%�� �����m���ر�A�7n��݆�n�����=�=��P騣:�.+=��N� '�����'�W�=�������磻Ͽ��X����{Ƽ�6:rָǉvl|����&���~�j2R�{uA��� wF�9�>Tn�#���ĩ�7�oF��� M��ү���1�k6��c5������������#�F��1���S�w�	���[�����`;zQ���r��	�V��@9��c��a�hD_����iTOr�lr��Q��՜"�\I<yB����;;��X���֋3�8}��������e�S������㻖��AѤg��]�׽��/#���Ǡp���+W��?���/�-�އe�Jy�.gu��i���Ȳ��V�^��ݜ@�rnW�S�:�n��S!]���]<�Ì.��s��>��o���������Q��᳏���������7����'10F������u6�'�_�`|.6��oo��[���񓷰?x��[S��������F �dD�R���U���,Ԙ���׳����\L/R��ߋ7��x��K4�^�xW�~�`
���� 3sX�_���a���0��������e�1_�	ۭ;=���7ɭ Q&�h�D�;��	��!�⽅��W��|AO�
d쨤��>O��竡�.h��P�8�Ӿl#����Ya{��襣q�]�`Ұ�i㲯��Ȇy����>��|��x���|uM�g⹸�g���~�/��B�kŜ5&���@�Xf3�A��mn��5g(!�\b#���j���|]��a)U�k�Z�5p��F���!t�b�
�nwLM�����8Ƙ �w���+���7�o�;�Mx؏VZ�rY�ر���8�Y�(��Ni]�T�fK@��z�
���{� OxN�d�v.L1~sW�~r7���z`�\��
���I���E���A>D�t�����ё�P=ˆrM��'� Ӂ�Y�Pz�Ig�L)E�e�A=��|�KHs�ux
�2�`β2����ݽ"$	5�u�R;+�bi?�<��57#�hg��_�4��k�嫙V�߈����R�"�4C5��/f����$,����:�B�P�p�sī1^*��L:?���j/@�i^��y'0,s�ܯ󬯘�뭘���;���	�J�A�ʱ�	���y�(��q����X<���LV�Rs�2<�TX"��	z�}:��ZW�����h>��#J����u�4�e0��G�6���~5��^�.�{�j��D�>_m�����"a�/�����8��D�hOH�Hf����P��r����$�R�Zg������3� 3����UY�)*{GzbX)U��&DS,��t(	�t��֓��7���t��)g&[��䜰� O�.�tp�p=>��ǩb?^;TkD�7��{E��p�ځ;���$�k -l5%��H�����)�q�a=�KֹR�$(W��i����g[�lk��d>�����9h�BAuAհ��[W��mbW�+���W��|���P������C�oM���^�̳�ITm%8��w�7����ѩ�JG�^�^ �SngK�A�/�ktn�"�� {{�����I2_n�^�1����h̽i��	T/�A�:Zn���
xNS$�q�j��P�~�vl|��O��?���鰙�:��կc`�{�Y�=��v�$Vʱob/A���(�f�c�����r���טv��D��M�g
��_b?�6I �uEE��k�{ �c���w�Ln���f��^5#/���~����Ƹ���`=(8���]wu�|r�u��r(�nd+]_����lwϵ�[Y��6��xZ끀�߅��^�`������?KS!�+�`W�n��Bܟ6��~<q@�:Q�4 �w�+&�	q��8������N24��%�;��� �c�x0E�:�y��E�(��wP@��E�8��1�h����1IքB��zoոL)DBH�-W< :�ؖ��Cn�Ņ۾0'�v��..�i��w���H��~�����Z�_�� �Ӈy:��d#���CO�8�W��堩���&e� ���2a-���5F��3F�݋�'e�	Q�|�tʽ���|UgCN}�xJ7���/�����1�H'��{�C�ܦ�
ñ.R&��3�hh�a��5��!����^����^(F�y��R�U�im��ԡ��攦�K�V�e�q�r8�ʱV��r��c�c/�]�W�S��	���,�d2��g:a���naoB�7&2��]�3�}ޑ�E�����_�=��s�x��kI��D�Nډd'�#\�$�R�Q�d:�𹹁oN��U���ȸ���ʃ�V����Af*(2����EFT3(2Iքf�'�è�����`HZm��z�}�_����N����4^���d�=jwh��#%g�W��v7D4�Z�ruE������ÔDƢ56R����B�i�!�XH��-�	��vy_-,r�-A���x�C�b�2�L�:I�>ݘ�D�XlF��Ku�
�<�|��R&)(�Biv�t���s/���H�����#���Ğ�N@oq!A+5��N7�8��a��\���V��r|Ք�T�5�;�SF��)��q��׉Br'�mn�7��]�ӹ��#ó�����jD��L�L�oXM�RQM4ȵW�KS�Gm�`�*��j
�B��a�Up%a(���'�ʻsqTDl��g�gl7w�+���{�_{�߽�kd�g���}����֧���/�����5�3X5~|����i:�z���S���X"m�W>�������oI��^J�M��?��?�~�����{�ڇ��}�{�����w-=�+i��X��'�؄>h�tr�����8��8�sO�ӣQ�k�qb;q��Â[�FHH,X�X!� ��Hl�f�;�N:�K�|m���|���v�帪�zߪ����/�������o~���w�o��?
���YŊ�V��j��pW��{~�?���џ��?�e�_��g��.H���7�����~���������~}�� ��v��N& �@h'�ō�,.�� ��v��N`��-��g�[���A�/	������a,hQ·�?���3�~�����}���A��?��ï�B~�� ����T0�
�@� �#�8�W�H�"j �`������e6�YZ`�mkf�� �, ���4��̼b��+����2���=w���K�6�6x�3s~��������?������c]�g�x:�E|��M�8�S�q�����Ļ��*��U����Hh
r���o�����w�Xm�7�umkl(y����VԚ��%Y�t$���*�.䰝�{\�$HLH\��m���N'�e���=�b܉���� ^=��?��~x�ǵN5t�A��1��rl�7����3
�⚢�*��&e*�К����c8�隩�(°J",¨,b"���4K��r���h%�׫�ϱ�U F���5���wt	k�b�Z��2�.W�A��{��_��[l��f��@��ʯ%wۛ{G������g��VO��h�*U�*V�2bQ�r���T��EN�b��	�\�{4u�&�d��-	���}.iZ*���;y�Q�?l��
�y#	��'N�MH�=��ÛL�A�P���M� ��UY�\�D�rUj��d^l���mn��(����Lӧo�moOޭZ*�y���gO�Jٵ�o�[l�2����Y����?_=�g�}�λӻ�U��.ܶƊہ[�۾�8U�AN4��R۱���LX�+��	�i�io+�A�C��dyH���烃���,�k����5���թg����%�T��,'�� މ7"ߨ��-��9L[o�|;�8<ܔ�6#�KR��i:�ί`�X������at��7�Օeѯ�~Ӿ�z���ۖ��Շu�<�|��%V�ЉD�Q�TLK�2WϞ���9��fJ��T�+U3��[�cϱ%�uI�5}�f���E��{uO^�81����4�!^P����+�y�����ɗ�-!Lk0��`��p����4q��3����Y�m��a���7 ?���p�I(�*Ɋ�vi:�;v����F�rS%������b?{��~%>��l�V_�!�-ԯKռ췜O[�N7Le:p�'���jS�Q���Zp��&��ګ�L�V)�<8�?ƍ�V{u؈�?}>al������c|�Y�cc�;w����r;+jæ��l���f�S[6}����}�>z�S@���S�N��bߋN��vZ�3!�����yQ���D��
߳����<�.�0
���忣��<�/�F1P�a����=y�_��O����%|	�i����32.����ߪ��FP�>��R����7z�l�߶,��tϝ������y��x�0���O#��0���c�G���p��o,ײ�����G����?	�?D��4Bk��k��:N)�F((M�(M�*I(���E��AS$�i��S����Aw�[U�w������_�I�����k(�[5%�B�Kl��y��Y;��x�"���Xs��4	�k�9���9������"̴�Q��򶵷
��X��Pis�mWm��S�����o�E�eD&����v��,}����H�ޞ7$�a�{�A�fɚ4X�II�R��1T�=jB��io��#_#�Sġ�Gi���A����W��A8��yB�������ǁ�1���#i������VE�&�'b�����?��0 T3�jP�8��u�q��P=��1`���p��`8���	����_�CO����P�c �!�?z��'������`?Mux�O^l�d������d>vgb��~t��O8��蓧�ϭO�>���f���BN�=�ke7/��*�(pm7[�;]�p�:�.W�]9�yB{媗Y�(�_������U*��#w2Wi�S����}~^�8/��.���'Y\�_/N��L��Jfɞ�5���eo��*M��%�f�&����J#T=ΫrR;G-���\OQ�e�h��o�1<L�,R��Y�V�D��y)�.�,�gZ��p�Ou��'%+������IR)�z춱w��?D�?�:a����P���)���������8�?���!i������\���G0�����������?�C��
�������������.�����?�����D����4(��I#t�RX��j����U��)�$1i\c0�U)�2L%Mԯ+�N�@��3!�@�#B������bcq[��͜׾���P9�%�R��e�צr�|T�Õ�3n�o�=�s����f��1�H����xz�,'S#�6����=�iA����}47�'\jn�������1�ӑ�t�@�㵈C��?�C��?���������8�?�����?�b������@����?@��oo���������������c �!�?���/������rO��P ���r��8����������y(x,�������D���Smm�Ҥ���S)��s\�bƝd��}����%�cZ�RCR��&$�t��������{_W��zch�MSd�[���p��:����,\i��W��m�;�p�"I�R��V��Z)(Uid�S�:Y_�H'p�zl@s�m�Bk�����S��j�e%Zj� J�T#���ѿ4�ރJ�.J��Js]�fjx��L��u39\�A��Z3���R�y�0Rzr�U)�4�m^��E[P�4��ôw#�ZrZw�*�F�<�ː:�0t#7y���C�����!\�������_��D�h�L�������d ��`�������Mٺy���F���q����Ktx�����#����Oa8��� �������k����È��������:��*�)�2jR�����:������"K�$�"��"&B,J�$I)@���F�?c���������g��vI�'�IQn�׷͎RaJ\o���jzR���ee�,KRxT�%�����B��m꺞�n���������R�ՆV��ym���U�Jei.���Y����T�Fo�>%{�|�����l����C
x�������P��p��{~��(���q����������3��)�(����@�����������!4��;����� �����1�D�����?�"r ��5�������	���FhaX�0YLU���b)T�(D���3u!pM�L��Y�1M�PX�5P0Q�Z����������B��%�j�.L�%���̋cj�H��=�k�\r�,jx��Mh�(��j���V����Ѫ-�FL�����T���ѳCiY1�jˀ`İ%8�f�0+&�E�jTcLi��*��}5���c�Q�I���BA��?�"r ��}�������!.��w�1��P�|������
�[�����v�W�+,��d��c�,��zs���b�֭��!��!�'�S+��YP(*
\m�������4���*���.�rgڰ:І��^Y�i���RD������[��rO��3�9��r�Zu�4�rU���R6I��B�z>��u8��Ֆ��V粢��[�D�:�u�aq�a���h��G[?�ؐS��qs�࿋����K�V���"��bM�Oۖ7�[č֢������ܓ�8�e�N��j����zE���f�LdG_�5��"ם�7�KK�W$��B料ֈ��E"9��^���l{�vK>s�z�[�*����#�,,���ZU֮tS|�Xi�tU)���%���~��]��LnHrV��Ϟ�=}Hh#�儔�uS
էye��5>����PAg�i���R���)a�Όn^oX��6�	e��s�j�����4Y��=Š��$Y�8�ہ�I7��z�X�@�+2Dj��� "��߷���?����?q��X��G�/>���B���_j;���<�a��sxs�n�2�H-��_��]�e�(�#Gyol@>��B0/Ձ�~��f�b��
��}4�����k<���!ĸ>�,��M�Vz���9��53Nٙy�L����M�9b�z��;4U)�ǌ5[)18��uNF�4���nǵ�8��~��!^���݇����}�Z=���Q��PlM]AWx�vKvM�ȍ��O���׺�'�|9��)BK*�����2�P��B��Di�Tڲ���S�{��C���CN���?CA���"r ��}��������
b��`�?2����������0��~��ߚ��] η�qŁ��`���Q��		!�`��a����?N������?��߯��#��_Q!����	��1%Q�Q)�%4�6�"��5qZ��@	�4Y�2q�@(M�T��p��["����;���j��o�3�?89�L+�x��5�MnjC��]]�s��3xoX�Σ��ưO[y9ob�4�)�)�<v�T��9�X��9\h�FT:{�B�3MP�
��:z����v�@ST�"�ʔojre�n����k���o�k�(ۖ��N�%y<3��Ry��}��w	A�_��vG��8�2!λn�%̮��	ö-�����܄2$�^`��t�r7�јA�=L|��ğ×�."�F���늲�E_�%��Ǿ���V �:�}]�Jb{�����[Aþ޵�/��7�ӟ&�R:��/|��3�=�A�B	�bl\\%.V�.�Y��o�'~�:������\$��m{�]���ҔA�r�+!���w��?��CSV�u��ä�6�`W��<��>���dj8n�Z�x$��#�.1f����]��y}�Թ�2{��'��4�A-�/���m�$��=�I�7�u�A��b�����KBp&0Q�Zy{\7ƃ�c��b[9���Zwol�k��Vbg#ėԕ���{{/�_�C�D��v�\.�\�R����@ �@Z�k�M��)�~�A�Ѣ�O��6���IAѴ
��H;�j��D)�l�;Z9s�3gΜ�GU�S�\Wk��v����;�5� ��1Xa薈�'�H<�`皪��[�E�X�a��XS�0��`�RqM�b}���8�&�f�?̹kI��-��K�z���������H]=^������>{��#]b����65.��y�?���8����#���\W��-0�@�:`^�n�v�is4�5(�0J�\(}Z4o��@n�ɖkLO����F���Lj�iZ�Y������� �4�Y���rM��&��1�>�A>#]B�'�K.�������Y����-�ב��g������ڍ����W��������Z�hz�n���C��C�PD��6�A�'T�S�w����fj�P�A�� A�h/
�C��[����*���_����/6K��ěs����W����六w��I�k_K���<������?� �O�?�w?��G/#���，�����^����'�����H�,r��� dn�s��eon0���!��9H��\�L��� [�r�#>�;��MV���H����.��}���t��������w�#��(^�=�\��RG�U<���&��zq\��J�[%�G5q��	���Ҍ��v,��+�P�]i��~������!�ċ��M�B��a,�P��ct:�;�6�� Ԓ�a1[Ά��S��a6L�&�"X��޻l�T,���Rgs�u�s�a�ǵ˕A��t+-���k{M�M�y�����e��ɻ��$�)�ev�������~�0�&��xx�����N��n�/��~�\[�B�>S��Ʊb��6E'*�x#Ԯ�+c�H �D�� �U/�Yw�Q���,r�r�C����I�3��R��+��z�ngD|(g���-������U�Bg�fe\��V)/w<�J��#D!r1�/��B�(�������\TI����cr��f���5+2�YI5���G����%p).��Z/��p�L"�$�T���$#�^��+��3d|�>�,vs�v���T#b�O�
��C�D�e��1Ky	f���6���8�fG����(��uh�X��Y��D��-$c���)B6��X�`Ohu��j&�rS!�H��z�&ҭ�/�,d��V�>��ƪ{M$��f�
Y��9f���=�Y������b`��}&�����/�B�[M$Ų/��f[$�1�h�<��%{�ax�K�|���B�2�6�@*���^�d?ZfI-b��f��,�%�%�M�B� wt��{���ҭ�͍=yV���z5�ǃ�"�du,�v��K��G�Jnܨ5�L�>�zbD��xs���\�Yb�<ǧF	��vj"��'
{�b�F�9f���=�Y
�M�?���.%q�,{(�xv0*gA��"쾿��d�	0u�H�����Q ��]�V"|%૶}�V��oQ�1�y|��S8�Y�m�Ͷ�l�m9�m�	ۖ׽��U�SIF���+��k�
z�}b屵g�OZ�ғB>�xB������*������֦�ոPSk�G>��7�DUA�G�F����]y�
�l�q��'�=B_@�G�#i��)$��/�>���}
EFV$N�ѕ�KS�D�F�U�<�1�*zyRyq���԰)qc�zkY}�o��z�ts}B���+�@������sa^�;�����g ���pXꛐmc���xZ=�� ��^�Bo�;��P�X�ܰ�w�5 tK����2���F�)�u�~%h>����K�랗���?^E�m��>{Q`/
�^�}�ԭ<��<��^��自��NE��w}�幃��+?xl�Vv�бXY�4�Cǒa~2��}Ȳ��8f�e3�B4KÊ�E b���u2%9&������ӛ|gx�K>*�%(~��-���r�G���	dmvⴟͅ����B�� �6���e�0�>�Yҧ�rT��½6��臉�G�D�-�g�Sx�YR��iSp"�X*��rH
#j$��gJ��Q��n�q([���NJ-��"S���t#�L�7�=oK$���p7�.��r`\�l��#y�Uw�az�b�BKڍ�	�Bx�mVCr	���_���N�K�|0(��L�X���[8αc�'V�+�g�Q�i�qy�C�ab-a�LK� &��}	 �h)�zkR���5-,Ϲ�g�ǯ�����|�l�s-��I���I[v)Y�#T�0���)��B��S��A�|�Α��bJ+�N��m�A�w��SN�'�\�)bb��N+Z�Z�����]�igHA��r��^�(ӊ���(���DKٓiIp���QO���V%Ys�C,����q����J�b���$^<��t��%�VgȬ/��3�����)��t�Mp�a�Q��#W��o�H�sվBx���{�ѮB���ZK�$�@�2l����g�p�6N��r!G���d/�I$������'6�Z�]���݈w��3r�}����<��ڇq�̣]���lᰅ���p\���L{��2�<6ʦJ,��Z�%���mmyQs�E)�JRr�ؒ"���J��p�@z��jx4�FCbd��՞C�1�)�Z����jTJ����(���(%I�?p�����ʜ���I�	������L"�~��`W��Ko����{�x��?�K����?�Y�&�ށ�Hu��Qǻ�i:]"�S����.��]u(!g�qn��w6�;����ג��5�[���?y�����[�׿�>������������?��$�{��w2Hyq�q��W�J��C���	\]Co�(����;_�����[�����|���3_G�F�O���F�����u����ء�vh��i�	�avh����q�ŵҶC���C;��N�f�m��Ch��-�1���*�	"�#��0�����~fQ@�Y�
C���zŁ�&�ѿ�	���;���ЄwQ;��6��8{+��J��lᰅ�#�3�D��%��#�ab|�o���4K��f������؟؟�����a�5|3s��}/�	�u|�s���pp�-����^a0�UŗN��<�����>]"��-r¶yh{��ȳ�?	" �������H�]��e8�d����z�Tz�G������U k�k<.7� �F���}X�HT�.5�Q�T�up2�|��
�8A�ց����� �M����ШC�+ ��@����� 
�������Ґu���:��gR�X����U���I���F�[$u�&O0Q�(Vb@�"B�@�����bSP�ippӨ�*S�2��� �Q�N��Ti��TiVRM����2V%�E2WN�JX��E�h������8F��t*��@-�3�����AJ2�l%��B��X@�14��h�5�U)��XH� z�����pDe�`V�s]Nѯp��lGZ}��qAx������N�� <�zeK�m�5ekNS��iж���.���d� �V�դ�J�*�$���|*`�:�� f�v��% ���1c�]� 2�i�`����\��(joۊ��b��֊��޲2|�5��",�3��� /:7�M�1se�9��NЎ�q�f/������(��a�&(t��=I�Ϻ��*�ʱRy�"�൫7|��������aM��P!�Ĝz���# }�hD����@�8!g� *�G�@?�Y�[ �qX��QTP[�9M��`Y����74 �O��عc�8X,����t=���<A�X�b��T��WSb�� �,'�kc���4��cl���z�Du�7)at��k�%�y��7�$��|�ľ�
:M`}�ֹ�X@�.���`:��um��h�([E^�"�``�8n��"��@B���h��:�}�`-���&�P ����	��A���B	��<�M�SEQT�=]����|��M�o���Se` �����Y�4��l`���ؓ��U�P��j�	l��r��7\�V�#Lj�{y��CΩ�x qf�4�1U�� ޜ{���t�LT�Ki0��o�p�6��6��$�����v_w��6<^:��w<�fc�� ��m�܅d�R�Ƥ�	��h�1x���	�\��s!��
^����9��&�%�80+#'(��1COX �wq`:�`�t�0�,�Y`�c�颜8��u��C+w[Ӛp���Ϩ�®�d���S��<w�	��O��i�u���i��4�&���Δĳ��<I8�zY���Ss7�,��*f�Ț��k2,�P~�L�v���*��d�M���(ӤT^Ik����v=��=���&��^�I�]`
�N-�ի3�2�`���elԭO�n�d�up�.�u`O+��z-[p��ǂ��EXX팒JCé	������p��7Zo83�YHbF�L�qb����l%����ͺ��D	2����S�fk��Lq�w���̳��:�̇y�Q���=��L��{��iZ8Pz'�持�u��0'���$Nq��`�Gcf,���h��.�{�����%+�v���=�<7p�8��[���gF��R%/轾 sRS���v�g�+b1���ay,��@���[�Y��Ƈ�����!v�v�h��1Oy����6+z����E� ���Ϛ�i�t�ꛪ;#��=[�9�{V��˳��ڟ�Y��J���Й�`��N]#,���֥i+��N��I�gQ���\L�Sq�!�ՠ77��@`�G����,���t�#m"j(3�9����:�/����R,�c<���s�_�}��$��k�:��E|����х���J@1q��:JY����2��J
Y<���ynZa�]�bC:\�SW,���u�p5��=��t���(Kh�:���g�Y }�9��:p���`i1��O��:erje3�Y���\��p���<���FgR[�@�R\��3���dJ���yA3����O �}i�� J�������-'�iPs�5�!����S͡g��I��v�n&bV������7՝�:��8P��,İ)+C|�:^�LS�cF�:jQ}F���X�7�� 9�VI4�2\�ޔ�����Ў���|O{L���%j����,/�)��]��.Հ|6����n���e��G�����5-��t/`C�}�3؀&�	yzz��n6`@w��[U��,��;ƣ��B{���:�;U���Tg���|(�#��F�b�>��r��\���|!O�>��� ,�I1���	ҏ��ͨ"��"4��7�
;����P+�s ���
=L�p����� ��%x�L���S �>zAކ�T�iCjpԐ�ۨ�R����3Vf	
pLC�'�௰~�4"J!l�����ڀ�����U�:8#
C��Y�=���<�V��FxR�o���q���#���ovj�x�_��.�Y�Jv������?Ξ����7�?Ξ����9<|ӏ�^��Da���I� ��d�Վ3����?`&f$������qh�JW?�K�B��sF
 ^���C��_Y��ӵ	-�1��
�;�I`�ÿ`�K�u>�Cy٘�ڪVL˴48:ഞõ�]�@�d�G�������g� ���#:f��5ۂ@����;�N����gԫ��pԡ�F�
�ў��%�|����T�Ļ�t�LM�m�:��.29N��``�y����8�	Ռ��z�Oi^L4�k�9� ��&t�����"����-X��D���+���ui��q�����b��@�T?�r8�����-��!��m��d�I�Oa��x-��+�?���,��!;g���:� &C����j ��7�_/ zЬ.� ��a������jx�Z�&#4���Z}A����cv�0&`�/r��MPE`��F s�2=x��!~4���/r���3�6ld��?��^wj��#M�r���A�`;��D8�X����%��)�:.ۑN�S���	��{�tߑ����y��+r���V��?��w�?.C���_��0�����~��?0��4C����*P��hH7|ɰ�u�|e`0ٯ��MU~5�vkM�T���:ב���������lt������d�����R]��	w���`4LhK�(�_�AK�w�
��l������:�;B����3��G<D����~ݿ� ��@"1A����"�ߜ�z�:M��Pk�{��˷Am�E���>�8qQ�����@�7 U��e~�ao4���4�ܣ�t0֦*��p�Ztx޾�@:i~�ΟȖjͧ&4Cú�3Ri��`_#���#�	N��t��jj��`~8/��Fhn+����2�ah�Y�"��Y�6"�Q�#���>������U���8����6��r�7Z�Hz�{�_�n���9��P]��9��B�{ 0D�yQDDR�EЎD��V<T�}�(��.'�	���_/4�� �|�ʯ�tq��L���!�_6r�+�O�t��gP��	���m|�pn�|ȆT��
L���#l�h�h��cC�yuט ������R4�E�����D��rݥ=3���N���cf��nu�J���j��tR'5IA>j�+��?�;������_�ޏ��<�\�S�b���|� :�3:'��I�Ӄ�� ��q�m
[68�m��1�:ĉ�9i��la���f��1dSd�xt��x��x�,0g� ����r{G2���'�7sK"����� ��|�/ W�C�-y!-��m,�>���w�謹^Q��9�ezw�$�o�>@YdYK��s�?�`g�c������c�
� �Ja���!�ȑ�����u�cѩ�ov
�(�Q]��u�F�� ���~k5�	�v��%� 
��]aڳ��$�А���L<��3^�*{�^��ӣԾ�eۅ6<�~�Fu�wx*C��
��+Y�d��O�����g+�W�2��W����a>����}���X.� ��y���[��M~ˁ6�� ������n0��&E�Np��1!�cD(��a�|*tO�iȀ�
O\ø�w��澀'�*
��e�VGS��s	�tI�1��`H�ߐ�ڟ�����,��#~���,���<
��E�&��_HղW�f� .��y*X�5��g�(�5��*��wQ:����(�=� �Ͼ#��ر�~��V���@Q��(J����c�4�yuC*�� iPf����Y+�R��nR��7Z( � � 1���&���`��-X���
�����Hu:�=P���2��(��SP-�P�C�n�dr2��H%-]1�p��I�����|�^&��$܅����\#)�����⟎��w��Q�������A24CV����q�9���p�O��.��R�o�1�ֆed���HB��6PۀC��;�<�{ȏ��0�4�O��c �RBe5,!�5�� l�<Cˑ>���%\z�C��Ew������� .�I�_��'�Y��Y�Ȋ�*p���%��{uv��?���v������d�@���g2/������9���y����������ó<^��,Ŧ��q�;���2�x}�3����C޳�?�zK��t:��?�Mݦ��j������	���C}}�9�h,P4�Q�?��;��H����������M����O�%2?�.b�Q���7���1��!���9��7��.-�$C0�c��6�3|��y��q���x��X�b�`9���*��<�s9-�VYC�QgRͤM��d]�.��4e���w�k�~(��_>�GQl�>��+�|5K*�-��7�ЖȊ���U�BC�d��7��f�M�na��/���_7�s?廵Tv�ͪ�Q��#�@"�'��NCl�y�����SUy�<��[���:���K�Fh:�-�����p]�nڃMG&:Nq,�����%Ow�Y��Ӛi�E��uL��ߑ��P�k7tB%	�?ͧ���^�㐸�t����`�{�O�3���b�+�x�+���ܴ��Q`��i�9��q�j2�j2�j�&_{f�#I��h �g�_�qH���;`�?A������%��l�g��0��!�������$���/��4������������M�602�\�Զ��|�NSv]�x�AO����nLA���%��55qɢ�q�Z0��Gmj;a����05���k����X�_S����zma�m+M�#$�%o.�7�g+�լ�Pi�����%�n�Ӄ��~�Y������}�/}(V]�*ŉ'y�r�h��o@Qh�{o9�Zw����8s����R<q�L���(��BC��@@����P|��-B�S�{���Em��"^�C���'��<�n)-���R�?8�T�x�ٺ�)�7���(#zO�b��h���	^S����*�&5���fw]B��%�l�SV��Q5oRfZ��2���\�m�2_��1+��$?�۱|Ә�#��]���������SI��G���0X��C����~c�?!������%������c�k�?v�'Ca�c���������?.������ī����O�`��c�����j7����������8����j��19��fh&m�95�j}�����Z6�sj?M�>��YF�iÙ}���i�gsF���?~�$����?�(���Q�ԥ����(���S#g���[5zb+��Bi��R��2��^�����ka]�����sI�����:�͌ٽ�x3_=R���,j݉�-�m�Y?���0a&�	}?cB~c.+�}��=ͩ�f5��� ��x�$a���?�'q��8�G��{�O���ד+�?�� I�����\Q��������p���š����l�l�/	���\O���G�1p%I����\M~,��ho����Zb5mR���K]��]�w��;�_l���	X,��P�,�X��B;?ЃF��T�y�V�5|���|xS'����
�Ԯ`0�d�qVFk?,2����{�Q_�r�X.���C�c�M[(9����g0g�T�Ӈ�����,�2�Yh�K��Ϋ�H��i^���^/O��2�%
�f�"{�(8>7�H��0��\�W<m0̭@�ܺ��3�NO��<�w��I=oN��]u|2h5Y�Ea$	V��V��0y��X�)1r�zY��M�:S��}����i
r�ڭ9�&��\��ޓ��)Eí��B��ҬBh�E���/>��*I��p���I�����,���������8����Z����ɐD����5����������'��o�^�g�4��c�$��8�����?V�.q��[��������c�����I������������odՌ��NkY��sfZKgy�T�t�`؜n�}���l.Mg���rT�ʘ9��e2���|��������.��`X���"���Q���b��)=��;T�a�R���x(߳��vW�����t�jiϮ����=��������{^<1)C�Ϻ�1��R�����$�.Rݝ%P�B�߹�����蚃	�x�f3��?�,?=�m�0�S8����Me0���O�.�������$	�?�����E����DJ���G�0���$��:����?��#���sW���������8�g,re�ǟ���`���m�g�����$�s<��l�I�s���jFϪ\��u��=��1����J�����>�Kg�}�TsٜIcG��$.��������W������;=�̕�4�6��J�q,!ko����<,�2mz������S��MS_�\���y�n:"_�J��U�;��`�Fْw����D�29U�JJ\�n\�m�5�i6:sF��&���Y���3��������\y�ǟ���`��c����������$�#��i��$��Μ���h�1����
<�e��_M��K/d�������tO��mI�����nL��C��X��NT��@qQQZ�v���ϥ��p���I��P�r�[ͩnu���J0���턝"J���Ģ
�m���2��הRoS�	�~F�6!L�m��x��M����{�̟��V��C����W�<��{L����f��:S[��U�E�K&u����H�(U�P��h�I|;Hd��R۫���S�����ˎ{c���g�<g�rv9�{cR~�r^�m�uj-M�3�Pw��0ZkO^ΐw��ʩ'��zOm?F$)�=��
9���ޭ�T�g��J��R
��N��|!_k��Q��V���r߾����zy���b�)�Y�Wy�sV��H|H"Yļ$��*7���F��-G�[*����Ϯ��fn���U��-�s+���q��]�گ�"��/
c��7����8u��S�T�|��`���p���ɕ�?�9�+��?�����}����Hb���]L��$��?���Q<��������y��].�{��)v�e%�����X�<���P.��7�qD�G��<�ā!�B[DY�,
jX4鄶�W�߃ "�����ݍ�d�[�����&]ZwKn�]{�R��*�������k�ܲ8�SD�s�ٹ��Y��چ���b&ߚ=�[�y�{߃ N?��߃��}�����/PDo�u�OZ�fI��R4Ԃ�/���P:�4_L���{��Ƒ���f�C}J�l�z���-�[���I�A�j[�[��v�v�*I�)RCR���9� ���9-rI�9�[�cn{I�{.9��(��rw���L[�իWUﳪX��̰�9.��8�K���̷f�٠(����b��IW��/;�ҝ�v�������(�����?���kI�������)�����ߣ��)�����_kI�D����(=��?X��d)X������`���������kI��;���1�u����d��ң���S�����֢֔����Ѧu����L&���HA���A����t�'�����Z��t+-no'��L"���fv���6�If3q�N���Զ���h"�̴wi���4���d���L��|���?��2�`�g-i�����b����Ź|��Ώ��N�s.�����CQ���K�E�;����Y�z[;������A�6�}�7���t,�N��ncǗ�D��.$��H�&�2D����Z�Y�*�(d�/�z2�s�J�<K�&���08���!�*�Pй+CSױ(��'���������w!)l��i8G�l��[�Cg�d|Þ`z�~t�t�����M��f���x&������$�JL�?Y �T���yk�ԧ�o�0�j��o����Pulʥp�5eW�iǿ/��ݹ�x�!v�e���8�V�F�\�qݶ�(;���+��N��9?켞�/�0�nE8u��h_��.D٬�=VS*w2e�F����d��m�}I���oCT�]1�Ҥk��/��k��z�O��"�IO���m������p����H$	��d�9P�瘖�{b��HL���V�1�E$1w��md����Q��Uod]S{�s�����|�V.6�y���bԔb�XmVd��n#a���`π�z����K��L� 8�&���ڲB�'.��ZX�@1���\�J�M�NKʱ��a�D[�n4eУ�>�V��3�l+��VMQV��P�p�$6d! �]�s&���le�-�[O�F�N��z-_��DE�x~��
U�\��k��3ʭ�J|��5���?nW��s�؆�	V��I�T����3��S(�~X-�!�,�/�ȇ5�m�j��18���&�׳������K{U� �X^�4�d8��L�c�}S8桭�b�n,B�q�iӵ��;��E����噲��̑��j�j������Jtu�ִ>@H�в�񕠓^�7�ԡ�_�j�ђ��i}3����ٍ���fw��@!��ب�:��pBϢ�y?c)�i��0�؇�.>]��#�z���t)O�t)6�eX�9IH�Vs��sr�O�O�=E��T)Ps��R6@�'���Dn�;m@�"fj�ޢ������T �)߲P�5��^��LY��R�/nMM%g MʪI��(Q"�B��58_c���I��O;�����݁0+��j�o��b��7�W|�����zV��E�r��0�����A���%�pv0��U�3�|^�V:��O�{U��/��]�F�c�@�Y~0gx�0+yʃZ�;��,@[�	싥2�+gpcJ�x>@�X=�/�������=�
B��Q���˃2�E�c�Ƙ{62�K�v�?v�nn��vcLE��>��Nډ�h!���㥙EX�a��m$O�T�5Eц(�5M��~�A ��A�[t$2��B���Dj!*5�
Ѱ�SHN���Bn48�%���Y�.�Ǧ��T-�8!�-Y�_TkG��=+�kѶ8P��0^PP��ٵ����|!/�{�.�_��K�F���c��Ec�xO38n����n��O�v+��x8q�@&�Y'����,��j�ܸ�c.��#O����af�9�/�5v���S�e4 Bt�9�����y,c�a�n{�u^�p��F��,��0+�YI�����Me�S��1؏j����5��l��&b	g
,a`	}-a�Z��%����0�@K�xOK8�廦.�x�S����&���O���I��ۉTbr�7���גb_�ȗ�<!ՠ-2P���>��E	>�-rn-�$'����[=���I�ג�f��D�&�L�}YT���rb��X8�qi�К������$"h]F���<9��iz'�X`F�\�O>�ęYV�LU�a\ܕuhl󎀻�&���Ch"vt
y�C]F�E�mE�"��l����c����@��*	�R�lAY�B$��!�^�"_��O�e^ ����R�^����}�?�$G����[�Ӿ�- 2e�I�b�&P:F���j��$�e	��v�K�����דQl!E�ɦ�[�ۅ�B�-�N2#�C!���ۖȞө�P����A����N^�+n�s�a�
<���l.^àE�� �� a�g�LьM�������b`�h�֣`p��G.���0�V�j�'�q��
X0h��`��k2~<'\
u^�o�?#>����y#&��&�f�#D?�M{WR�)��6`��m�A��hc����sb�Ud�x�zG���du����.[�ǲ֜ɺZS#���P�k6%��Fǩyp��:�1�Ч���B#Xn't�W�v�@�b�j��#'��׶��tT�so%"��~c�<#����������o��� K�C$tc�-
h��� ��O6�⛾��
�5M3�SK��u"��}��s�%�" �����,ܩ�G{po�C��A�򐈻����vk�Zoqlr�&�z���~@&�Eq���æbk�@W��rߍ���%�s�ښ�7%
^�P�!�Z�
��u}��KѧE�ț1\��M����W4&��m��"���a�7�����f�ldz@P�|�#��h@�~��>��ʡ{�*�_��`�6��מ�yT� ���eڣkq�PkN�-U��L���PU� z8Q��� ���Y��"�A��kP��A�	}b���1�F�d3�*HH�W�EU��X'���ҿ�D&����Vd
�*Z�� �'>_%�n�#&�r����yqd�~�l ��kξ(+���{y�%���B���fW׆L�x]�t4�>8����첽�mf.a�S;r����x\8���1��f�?����3z�*˴�.ݰ�{H��m`,�(v��;�V�^����Hd�XUC���>`���N����΅�q�H.��W�-����т�p?���APd@A��ΊE^"��3{���ny=	�;�~a(��72z �<�#3�� �OT:g,���#bu.�U�D6�����^�������\�ܟU@�v��.-�CQ6=Ώ1�)#�aҡh8���t��CΧl��TZi�L}��rFw�:����NM����Q0�����g���ƚ�����V6q΢-�`�)��-=e]4ř06���$Jo���E�&�:�2��@��w�.����_l�E���t���B^8lճZ��&��>L6�h���|C�Bw 8���p��d�w���&�ɝ�I�.�nT���B��w@�}������emO ,��LP�n%��AP4p\W���{���d:��XK����^b
	M��У�D�g�ň���j9g�6�c�V���龨����������{&f��J�oRQG��?1��G:�J��x���wW9��Y i,g��kZ
��\�E�u��n�������&=�{$���_�8�{���u�l����،r�K��R�N�e��*J
��}��Q7W �"��������ߵ����j/Ǵ��U�<�¨���N5#�rW1Z�L5��\��w_X������A�0�;:`z�}���~4�dX�|�tF�0Y����֨dإ�1�Iw�o��1�l[�n:��	�|��p�~����N�A�I��CT�j�w~��!6y737�vMm��Է�!��F|���J�ߞE��שe�[�E�?��L���n�֒�[���Ԁ�2�qk�9x�8��lT��5n������$�$_}E��>�zI*'8	�zF�;�h2�l��?cr{��
�j��c�"�c+��'dx��x@��U��	O,��81�w���'?+X˲�a��v��÷�+�I�&;�cN �c�o r�<U��i	���q.���/����'����ב��.�|�x�S���/������㿉8
)+��}��e֕���.�|���o|r�7�I��X���OfK��	��e��ڏ�̄����RL���)�U-]h>�E��u�����şϖY����L0����X����?��sV`��.��7,p�l��\�0�!ۍ��){F�XvR�~?�.66�2*���,* L��*����|Ӣ�_�����.	�ԣ8�o�7��:�ā\h��(��'�EB�W��
��I�E+|��ׄ�9;0��/������^��!�:�*�yb�m�}��'I������>o�����_狞���0넄GM� =2�������N��=ψ��B�W�>����Y�\��>�a�V=>�֠�nL4i
~���^ex��	��A�YhEV��c��!������w�q���L��������O-�0�2����ϖ��@�O��x6��֒�������
��������?��N���@VZ�E��b���yg��������qW/ءP�+��nb*D��qς���]�3��V,=����愇���ϗ*<�k��c��x|���d"����D����	2���0����w2-/�����������L"��Z�m�-���g.>���qV�'2A��#��+T��}�>j�F���K��vV�s7u,�L����?�� ��wH�JZ���v���}Q��5��.wZ"-��Kd��/�JeY��?�`�o-	UUC1�if`��/	A����!�,��9�
H��Mn�4Sxq͍�sB)�*��o����@G�` �h���#q`v5�U<����� �<��h�� �7���h#]��7'�#"5&hʀ�������ţ��*����}tK�u	�x��8W+��*5�>F����c7h�}wa�U�֨�K]����f���T)g�k� �pAG�|������;�
�F;oe++����X����;��IccY���R�0yϙ�Xu0�������D�����8��$������o��]���~������_7��.K|���D;�O�ۻ	H�⮘hfR����Tr��ijW̤��v;��N��HK�	)-�$(��OH�x�ؓ?�c�?��~�?�_�Q[�����W��o�_��G�_�F���WGO�%�=�ܫ'�~��?�F7�<�����?�~���O���'��|,���R��tU,�k�u��2�u�.�߿���>�w�������îtR�K��UyX�_O���{�v����O*�'n�/^W
��uaj�û���ݩ�x9_8�n���n<j�
�g��R�K�O^'���g��⭰�LJ�ڋf��K��|ٻH}�Z�]�dk��y{�ۛ�_�?��<�#\�_�v��!_�_�+�K�Ľ�	�|�.{�
��~�\��|�奣��e�;�tz[��+���<|yY)�y�6T�\ˮ��w���X~Y�ꔄZ��/\?;}Չ�(����U�|x�9��<�j���קm�S�T�w�~j,݉��R׵#Q</��L�H?�Ǫ���e�(_�i��.w�?Z�4ţ:0M�h1���wu1�[U�[���nww֫��B;R���q�_�J���N�8Ώ@�q�ǉ�8�?�@���@�oHR%*�g�xB�'x���*TP%�(�/�Rp�I&3�?3�a��{�!��s�{�9���w}�Tf��0e7��D���T�j3>u̐�6�����Dk��>�S��gR�ܪ�V/���^b=�����т���7��-�NxK[�Á5��,0͜�3�MKc�CKSa�sC��C_b��S
��e��l&u�u��W<ڇ��**���Jy�e���S�;`*%oP�%g��Ւ������%�J)b���V�'��<M7��lن�y��ۖ�8�
U@�ư��dsJ��Ls�X�(W�!��]���;�+��Q�#g�G�,�IPx'5 ����V�X�
�Xҕ�<��S��1:�)
��������x��Sx�&nY��y? AI��]��^qw�V0�.eV��1d`n�,䥥��(.�]��1�6ESr!������V�T�N[L7��&��L9��&��&t�����`\�)��Xئ�X7N�ޞd��,F�{:1�L���R��Cǘam�h���Sfc�@�K�dk�L3ǹ\<�������^�d9BՒx�xgg�k��1�+�1²>��`baS�-��2�V�.G"��\P-�&�����ӆ���ʇ!�h�2�d!k��t�V5:����H�"�G��x�뚒�O,�kXN�YM�8@(��"+��%O�9\����1_��HCƏE�#ʇt�+8Y��ù�%�e���s&du@��r�\��\<�{z��Da��`PPy�>�z��?5���Lu���)�v�

w�X<���5���E=���Å��tƙ\�����h�]�+�oZӥ�r\1��Qگ�D߫3�(����H�2b+���1^,V�&����T,Isʖ�Kl)��$I1E����;f,G����X�Q2��G�c>G;�FJ�t;Yt	<4�[����Ԃ��Xf~�\���Qi��Y�'�=����f6K�-�hhh>XcI��X�[�wgc��X2�6��麡������֌ e?�5'��+�J�(��>,�N"9b�@(��aq,��jS�t�!f���%e`����ʶ�Ԍ�Qr��� �\(_�
q�X�(ҽ��(��c����GmO2+#�ܙ*��x�K�Y��rX*��m��׵F������Ӗ��:�ūٖ^剙�d˓�r'c�E9��P�v��m�<����%�c�Q{�9ؗ��o��v�-�|����C;��'6o�ו"`���=�~n��6vi�����K�z�T��y<A�_k?�dO���1�h8�9k��%z�e�9�j3�*v\��|�	hY�/���/��7�[�a]lk�R���n���Qg�����8�e�Uv����~{���o�|��v��s럹��kإ��``����k���j�t�]_�{
�(?����m��_����۝{�:� ��[,.��u�=l�,�<c��v�@�o���|��Ů ]lb�������^|�!�\Y"/�lcoc�>8�)@7'�)x��S�0����j�V�>G:��4Q���g��HZ=��� ۡLIq\@/�;�u�Z�gU)��ܢhJ�0��j0�E�-I����=I.��I���@���e�S�0G�%��1��<V]NA���@Y�霊�����H�I�~%$iv�QSAY*���e����[%�4��f��jXd���p�m�w���Bn�l/"�4>��=�땹�(���[�)�$Y��v�nܧ�B`xL�MrFԔ)sZ&h��+�Ԃ�6ۑ��Q�u�>U�`da����q�t`n�B!�y򔙟���X9'�Ŕ�+ǡSlJn[NbD�	-������P�/�	Ii9���(	.�oh��Pd�3��Ȗu6B��R;'�k�=ߛ9>9I6<�M�T�5Js"1�2���R���5�UV���`^j;e7�j�wt�]��9�s�%�dI/`�I�S��y>���l�X�L'�A�3�/b��OoT��]XW8�yWV��Vx��V���?_�s��/B��w���N"�pD�V�z��v���*B'�g�c4��g�L����Q���<��0p��ȪU`	�l6kó���0� C�b!�0��z9�����Q֌�9H��9��CIBa��	�S��&TCb���`��]�Ñ	�����f^L��E�)�J�`�Q,�9�B�Ҵ��@�N��ɷ�J�1"C���)BH.M��xd�H&��B�a$p�\m�ü5��ru�m�T���!\UdB�T!�+�$"��vɫì�n�i�� �t��T;�"?�L�0��T8�I���9���s�*�	F�N���O���q��D��	`����؎�Ǻ�;�
���OF�p�߁\�P��G4a�>ߩ���v\\m�X��V���O
-�~B��a�8_`8;k@�D���1uޤ`<��Z��/�5���W~�Q����_#��~���������W?�
���6����4��a��=2��v�5��׷ߕ�IF��?#����;Ͻ���ui��~��oaW.�������׾�����`?̀�3�'Oo�����_/���\�}�]�v�kf�y�_~����[O~c7�Y���~��װ�������y����.��aj���ډ���ډh�&����)��).� ����ډ��(gC9ۧ��yj��}��8��$4�8�Fϡ��\PY�5�[BWπzfx�CW}�����Wױ6�	�`�g��:�3@�RѣT�3@΁����#y���AfX'_l,��]���� ���A�в �f9r���f��������2��Y�p���NJ���Gϐ�yV��um���H� A�	$H� A�	$H� A��� �K   