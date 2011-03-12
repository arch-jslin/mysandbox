
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack

-- ��ڦb�ˬd�W�A��{�ƫe�٭n�� intersects �U�h�|���|�y�� column �����z���A
-- �άO row �B�ŤF

-- �@function chain_limit
-- �@�@//��X��� 30011 �I�_���զX => �G�o���d��uA ��Q a b c �I�_�v�����įq�G
-- �@�@stack = {30011} //�q��Q���̩��U���զX���H�����@�ӥX�ӷ�
-- �@�@iterate on�uA ��Q a, b, c, ... �I�_�v�� a, b, c�FA �� stack[top]
-- �@�@�@push one of {a,b,c...} into stack
-- �@�@�@�̷����D��ܪk��{�L���A�ˬd�G
-- �@�@�@���঳�H�B��
-- �@�@�@�@(���Ψ�{�L���]���ˬd�H�ڥi�H keep track �ثe�L���C�� row ���d��A
-- �@�@�@�@ �æb�����D��ܪk�����q�N�簣�\�U�h�@�w�|�B�Ū�)
-- �@�@�@���঳ invoke (�b�٨S�W�⪺���p�U�|���o���D�ܡH)
-- �@�@�@iterate on colors
-- �@�@�@�@��J�o���I�A�õ��Ӭq�W�� (���ݦҼ{�o���I�C��)�A���ҥ��T�ʡG
-- �@�@�@�@�s�P�o���I�Ҽ{�A���঳ invoke
-- �@�@�@�@�����o���I�ô��կ�_�]������L���A����ѤU�F��
-- �@�@�@�@if ���S�ѤU then ++chain and break loop
-- �@�@�@end
-- �@�@�@if �Ҧ��C�ⳣ�չL�٬O���ѡApop stack
-- �@�@�@if time >= time_limit then return nil to indicate generation failed
-- �@�@�@if chain >= chain_limit then break loop
-- �@�@end
-- �@�@if chain < chain_limit return nil to indicate generation failed
-- �@�@�N���D��ܦ���{�Ʀ��L��
-- �@�@return �L��
-- �@end 

math.randomseed(os.time())

local PuzzleGen = {}

function PuzzleGen.generate(chain_limit)
  local stack = Stack()
  local intersects_of, starter = MapUtils.create_intersect_sheet(6, 10)
  stack:push(starter[random(#starter)+1])
  
end

PuzzleGen.generate(7)

