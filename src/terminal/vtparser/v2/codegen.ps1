$namespace = 'v2'
$StateTypeName = 'VTStates'
$GenerateStateEnum = $true
$MaxChar = 127
$ActionPrefix = 'Action'
$Includes = '<cstdint>','<array>'

$Ranges = @{
    'C0' = '00-17,19,1C-1F'
}

$Anywhere = @(
    @{ exclude = 'Escape'; key = '18,1A'; value = 'Execute','Ground' }
    @{ exclude = 'OscString','OscParam'; key = '1B'; value = '','Escape' }
)

$States = [ordered]@{
    Ground = @{
        '@enter' = ':EraseCachedSequence'
        '$C0,7F' = 'Execute'
        '**' = 'Print'
    }
    Escape = @{
        '@enter' = 'Clear'
        '$C0' = [ordered]@{
            'IsInput' = 'ExecuteFromEscape','Ground'
            '_' = 'Execute'
        }
        '7F' = 'Ignore'
        '20-2F' = [ordered]@{
            'IsInput' = 'EscDispatch','Ground'
            '_' = 'Collect','EscapeIntermediate'
        }
        '58,5E,5F' = [ordered]@{
            'IsAnsiMode' = '','SosPmApcString'
            '_' = 'Vt52EscDispatch','Ground'
        }
        '50' = [ordered]@{
            'IsAnsiMode' = '','DcsEntry'
            '_' = 'Vt52EscDispatch','Ground'
        }
        '5B' = [ordered]@{
            'IsAnsiMode' = '','CsiEntry'
            '_' = 'Vt52EscDispatch','Ground'
        }
        '5D' = [ordered]@{
            'IsAnsiMode' = '','OscParam'
            '_' = 'Vt52EscDispatch','Ground'
        }
        '4F' = [ordered]@{
            'IsAnsiMode && IsInput' = '','Ss3Entry'
            'IsAnsiMode' = 'EscDispatch','Ground'
            '_' = 'Vt52EscDispatch','Ground'
        }
        '59' = [ordered]@{
            'IsAnsiMode' = 'EscDispatch','Ground'
            '_' = '','Vt52Param'
        }
        '18,1A' = [ordered]@{
            'IsInput' = 'ExecuteFromEscape','Ground'
            '_' = 'Execute','Ground'
        }
        '**' = [ordered]@{
            'IsAnsiMode' = 'EscDispatch','Ground'
            '_' = 'Vt52EscDispatch','Ground'
        }
    }
    EscapeIntermediate = @{
        '$C0' = 'Execute'
        '20-2F' = 'Collect'
        '7F' = 'Ignore'
        '59' = [ordered]@{
            'IsAnsiMode' = 'EscDispatch','Ground'
            '_' = '','Vt52Param'
        }
        '**' = [ordered]@{
            'IsAnsiMode' = 'EscDispatch','Ground'
            '_' = 'Vt52EscDispatch','Ground'
        }
    }
    CsiEntry = @{
        '@enter' = 'Clear'
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '20-2F' = 'Collect','CsiIntermediate'
        '30-39,3B' = 'Param','CsiParam'
        '3A' = 'SubParam','CsiSubParam'
        '3C-3F' = 'Collect','CsiParam'
        '40-7E' = 'CsiDispatch','Ground',':ExecuteCsiCompleteCallback'
        '**' = 'IllegalCsiDispatch','Ground',':ExecuteCsiCompleteCallback'
    }
    CsiIntermediate = @{
        '$C0' = 'Execute'
        '20-2F' = 'Collect'
        '7F' = 'Ignore'
        '30-3F' = '','CsiIgnore'
        '40-7E' = 'CsiDispatch','Ground',':ExecuteCsiCompleteCallback'
        '**' = 'IllegalCsiDispatch','Ground',':ExecuteCsiCompleteCallback'
    }
    CsiIgnore = @{
        '$C0' = 'Execute'
        '20-3F,7F' = 'Ignore'
        '**' = '','Ground'
    }
    CsiParam = @{
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '30-39,3B' = 'Param'
        '3A' = 'SubParam','CsiSubParam'
        '20-2F' = 'Collect','CsiIntermediate'
        '3C-3F' = '','CsiIgnore'
        '40-7E' = 'CsiDispatch','Ground',':ExecuteCsiCompleteCallback'
        '**' = 'IllegalCsiDispatch','Ground',':ExecuteCsiCompleteCallback'
    }
    CsiSubParam = @{
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '30-39,3A' = 'SubParam'
        '3B' = 'Param','CsiParam'
        '20-2F' = 'Collect','CsiIntermediate'
        '3C-3F' = '','CsiIgnore'
        '40-7E' = 'CsiDispatch','Ground',':ExecuteCsiCompleteCallback'
        '**' = 'IllegalCsiDispatch','Ground',':ExecuteCsiCompleteCallback'
    }
    OscParam = @{
        '07' = 'OscDispatch','Ground'
        '1B' = '','OscTermination'
        '30-39' = 'OscParam'
        '3B' = '','OscString'
        '**' = 'Ignore'
    }
    OscString = @{
        '07' = 'OscDispatch','Ground'
        '1B' = '','OscTermination'
        '$C0' = 'Ignore'
        '**' = 'OscPut'
    }
    OscTermination = @{
        '5C' = 'OscDispatch','Ground'
        '**' = '','Escape','@Invoke'
    }
    Ss3Entry = @{
        '@enter' = 'Clear'
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '3A' = '','CsiIgnore'
        '30-39,3B' = 'Param','Ss3Param'
        '**' = 'Ss3Dispatch','Ground'
    }
    Ss3Param = @{
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '30-39,3B' = 'Param'
        '3C-3F,3A' = '','CsiIgnore'
        '**' = 'Ss3Dispatch','Ground'
    }
    Vt52Param = @{
        '$C0' = 'Execute'
        '7F' = 'Ignore'
        '**' = ':HandleVt52Param'
    }
    DcsEntry = @{
        '@enter' = 'Clear'
        '$C0,7F' = 'Ignore'
        '3A' = '','DcsIgnore'
        '30-39,3B' = 'Param','DcsParam'
        '20-2F' = 'Collect','DcsIntermediate'
        '**' = 'DcsDispatch'
        # '40-7E' = '','DcsPassthrough'
        # '3C-3F' = 'Collect','DcsParam'
    }
    DcsIgnore = @{
        '@enter' = ':EraseCachedSequence'
        '**' = 'Ignore'
    }
    DcsIntermediate = @{
        '$C0,7F' = 'Ignore'
        '20-2F' = 'Collect'
        '30-3F' = '','DcsIgnore'
        '**' = 'DcsDispatch'
    }
    DcsParam = @{
        '$C0,7F' = 'Ignore'
        '30-39,3B' = 'Param'
        '20-2F' = 'Collect','DcsIntermediate'
        '3A,3C-3F' = '','DcsIgnore'
        '**' = 'DcsDispatch'
    }
    DcsPassThrough = @{
        '@enter' = ':EraseCachedSequence'
        '@exit' = ':ExitDcsPassThrough'
        '$C0,20-7E' = ':HandleDcsPassThrough'
        '**' = 'Ignore'
    }
    SosPmApcString = @{
        '@enter' = ':EraseCachedSequence'
        '**' = 'Ignore'
    }
}

$CsiDispatch = [ordered]@{
    CUU_CursorUp = 'A'
    CUD_CursorDown = 'B'
    CUF_CursorForward = 'C'
    CUB_CursorBackward = 'D'
    CNL_CursorNextLine = 'E'
    CPL_CursorPrevLine = 'F'
    CHA_CursorHorizontalAbsolute_HPA_HorizontalPositionAbsolute = 'G', '`'
    VPA_VerticalLinePositionAbsolute = 'd'
    HPR_HorizontalPositionRelative = 'a'
    VPR_VerticalPositionRelative = 'e'
    CUP_CursorPosition_HVP_HorizontalVerticalPosition = 'H', 'f'
    DECSTBM_SetTopBottomMargins = 'r'
    DECSLRM_SetLeftRightMargins = 's'
    ICH_InsertCharacter = '@'
    DCH_DeleteCharacter = 'P'
    ED_EraseDisplay = 'J'
    DECSED_SelectiveEraseDisplay = '?J'
    EL_EraseLine = 'K'
    DECSEL_SelectiveEraseLine = '?K'
    SM_SetMode = 'h'
    DECSET_PrivateModeSet = '?h'
    RM_ResetMode = 'l'
    DECRST_PrivateModeReset = '?l'
    SGR_SetGraphicsRendition = 'm'
    DSR_DeviceStatusReport = 'n'
    DSR_PrivateDeviceStatusReport = '?n'
    DA_DeviceAttributes = 'c'
    DA2_SecondaryDeviceAttributes = '>c'
    DA3_TertiaryDeviceAttributes = '=c'
    DECREQTPARM_RequestTerminalParameters = 'x'
    SU_ScrollUp = 'S'
    SD_ScrollDown = 'T'
    NP_NextPage = 'U'
    PP_PrecedingPage = 'V'
    ANSISYSRC_CursorRestore = 'u'
    IL_InsertLine = 'L'
    DL_DeleteLine = 'M'
    CHT_CursorForwardTab = 'I'
    CBT_CursorBackTab = 'Z'
    TBC_TabClear = 'g'
    DECST8C_SetTabEvery8Columns = '?W'
    ECH_EraseCharacters = 'X'
    DTTERM_WindowManipulation = 't'
    REP_RepeatCharacter = 'b'
    PPA_PagePositionAbsolute = ' P'
    PPR_PagePositionRelative = ' Q'
    PPB_PagePositionBack = ' R'
    DECSCUSR_SetCursorStyle = ' q'
    DECSTR_SoftReset = '!p'
    DECSCA_SetCharacterProtectionAttribute = '"q'
    DECRQDE_RequestDisplayedExtent = '"v'
    XT_PushSgr_XT_PushSgrAlias = '#{', '#p'
    XT_PopSgr_XT_PopSgrAlias = '#}', '#q'
    DECRQM_RequestMode = '$p'
    DECRQM_PrivateRequestMode = '?$p'
    DECCARA_ChangeAttributesRectangularArea = '$r'
    DECRARA_ReverseAttributesRectangularArea = '$t'
    DECCRA_CopyRectangularArea = '$v'
    DECRQPSR_RequestPresentationStateReport = '$w'
    DECFRA_FillRectangularArea = '$x'
    DECERA_EraseRectangularArea = '$z'
    DECSERA_SelectiveEraseRectangularArea = '${'
    DECRQUPSS_RequestUserPreferenceSupplementalSet = '&u'
    DECIC_InsertColumn = "'}"
    DECDC_DeleteColumn = "'~"
    DECSACE_SelectAttributeChangeExtent = '*x'
    DECRQCRA_RequestChecksumRectangularArea = '*y'
    DECINVM_InvokeMacro = '*z'
    DECAC_AssignColor = ',|'
    DECPS_PlaySound = ',~'
}

$Execute = [ordered]@{
    ENQ = 0x5
    BEL = 0x7
    BS = 0x8
    TAB = 0x9
    CR = 0xD
    LF_FF_VT = 0xA, 0xC, 0xB
    SI = 0xF
    SO = 0xE
    SUB = 0x1A
    DEL = 0x7F
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

$csiDict = @{}
$CsiDispatch.GetEnumerator() | % {
    $fn = $_.Key
    $_.Value | % {
        $id = $_
        $key = [int][char]($id[-1])
        $r = [pscustomobject]@{id = $id; fn = $fn}
        if ($csiDict[$key]) { $csiDict[$key] += $r}
        else { $csiDict[$key] = @($r) }
    }
}

$executeDict = @{}
$Execute.GetEnumerator() | % {
    $fn = $_.Key
    $_.Value | % {
        $executeDict[$_] = $fn
    }
}

function array_to_set($arr) {
    $set = @{}
    @($arr) | % { $set[$_] = 1 }
    $set
}

$Anywhere | % {
    $_.exclude = array_to_set $_.exclude
}

$impls = [ordered]@{}

function fname($s) {
    if ($s -is [string] -and $s) {
        if ($s -match '^@(\w+)$') {
            $Matches[1]
        }
        elseif ($s -match '^:(\w+)$') {
            $v = $Matches[1]
            $impls[$v] = 1
            $v
        }
        else {
            $v = $ActionPrefix + $s
            $impls[$v] = 1
            $v
        }
    }
    else {
        ''
    }
}

class FuncBody
{
    [string]$exit = ''
    [string]$action = ''
    [string]$newState = ''
    [string]$enter = ''
    [string]$actionAfterNewState = ''

    [string]fkey() {
        return $this.exit,$this.action,$this.newState,$this.enter,$this.actionAfterNewState -join '|'
    }

    FuncBody($state, $def) {
        $States = $script:States
        $def = @($def)
        $this.action = fname $def[0]
        $this.newState = $def[1] ?? ''
        $this.actionAfterNewState = fname $def[2]
        if ($this.newState) {
            if (-not $States[$this.newState]) {
                throw "Invalid state: $($this.newState)"
            }
            $this.exit = fname (${States}?[$state]?['@exit'])
            $this.enter = fname (${States}?[$this.newState]?['@enter'])
        }
    }
}

class FuncBranch
{
    [string]$cond
    [FuncBody]$body
}

class Func {
    [int]$id
    [FuncBody]$body
    [FuncBranch[]]$branches
}

class State {
    [int]$index
    [string]$name
    $charFuncMap = @{}
    [Func]$defaultFunc
    [string]$enter
    [string]$exit
}

$funcReg = @{}
$funcList = [System.Collections.ArrayList]::new()

function add_func($state, $val) {
    $func = [Func]::new()
    if ($val -is [ordered]) {
        $func.branches = $val.GetEnumerator() | % {
            [FuncBranch]@{cond = $_.key; body = [FuncBody]::new($state, $_.value)}
        }
        $func.id = $funcList.Count
        $funcList.Add($func) | Out-Null
        $func
    }
    else {
        $fbody = [FuncBody]::new($state, $val)
        $fkey = $fbody.fkey()
        if ($funcReg[$fkey]) {
            $funcReg[$fkey]
        }
        else {
            $func.id = $funcList.Count
            $func.body = $fbody
            $funcList.Add($func) | Out-Null
            $funcReg[$fkey] = $func
            $func
        }
    }
}

function range_to_idx($s) {
    $s -split ',' | % {
        $v = $_.Trim()
        if ($v -match '^([0-9a-fA-F]{2})-([0-9a-fA-F]{2})$') {
            $first = [Convert]::ToInt32('0x'+$Matches[1], 16)
            $last = [Convert]::ToInt32('0x'+$Matches[2], 16)
            $first..$last | % { $_ }
        }
        elseif ($v -match '^[0-9a-fA-F]{2}$') {
            [Convert]::ToInt32('0x'+$Matches[0], 16)
        }
        elseif ($v -match '^\$(\w+)$') {
            range_to_idx $Ranges[$Matches[1]]
        }
        else {
            throw "Invalid range value: $v"
        }
    }
}

$stateList = $States.GetEnumerator() | % {$index = 0} {
    $state = [State]::new()
    $state.index = $index
    $state.name = $_.Key
    $def = $_.Value
    $Anywhere | ? {-not $_.exclude[$state.name]} | % {
        if ($def.Contains($_.key)) {
            throw "State '$($state.name)' conflicts with Anywhere event '$($_.key)'"
        }
        $def[$_.key] = $_.value
    }
    $def.Keys | sort | % {
        if ($_ -eq '@enter') {
            $state.enter = fname $def[$_]
        }
        elseif ($_ -eq '@exit') {
            $state.exit = fname $def[$_]
        }
        else {
            $ch = $_
            $val = @($def[$ch])
            if ($val[0] -eq 'CsiDispatch') {
                range_to_idx $_ | % {
                    if ($csiDict[$_]) {
                        $val[0] = '@CsiDispatch_' + $_.tostring('X')
                    }
                    else {
                        $val[0] = 'UnmatchedCsiDispatch'
                    }
                    $func = add_func $state.name $val
                    $state.charFuncMap[$_] = $func
                }
            }
            elseif ($val[0] -eq 'Execute') {
                range_to_idx $_ | % {
                    if ($executeDict[$_]) {
                        $val[0] = 'Execute_' + $executeDict[$_]
                    }
                    else {
                        $val[0] = 'UnmatchedExecute'
                    }
                    $func = add_func $state.name $val
                    $state.charFuncMap[$_] = $func
                }
            }
            else {
                $func = add_func $state.name $def[$ch]
                if ($ch -eq '**') {
                    $state.defaultFunc = $func
                }
                else {
                    range_to_idx $_ | % { $state.charFuncMap[$_] = $func }
                }
            }
        }
    }
    $index += 1
    $state
}

function chunk($arr, $n) {
    $ls = [System.Collections.ArrayList]::new()
    for ($i = 0; $i -lt $arr.Count; $i++) {
        $ls.Add($arr[$i]) | Out-Null
        if (($i % $n) -eq ($n - 1)) {
            ,$ls
            $ls = [System.Collections.ArrayList]::new()
        }
    }
    if ($ls.Count) {
        ,$ls
    }
}

$funcIndexType = $funcList.Count -lt 256 ? 'std::uint8_t' : 'std::uint16_t'

function gen_table() {
    "static constexpr $funcIndexType _table[][kMaxChar + 1 + 1] = {"
    $StateList | % {
        $state = $_
        $ids = 0..($MaxChar+1) | % {
            $f = $state.charFuncMap[$_] ?? $state.defaultFunc
            $f.id
        }
        "{ /* $($state.name) */"
        chunk $ids 32 | % { ($_ -join ', ') + ',' }
        "},"
        # "{ $($ids -join ', ') },"
    }
    "};"
}

function gen_func_array() {
    "static constexpr std::array _funcs = {"
    chunk $funcList 10 | % {
        "    $(@($_ | % { "&ParserGenerated::_func_$($_.id)" }) -join ', '),"
    }
    "};"
}

function make_call($f) {
    if ($f -eq '@Invoke') {
        'Invoke();'
    }
    else {
        "(static_cast<Derived*>(this))->$f();"
    }
}

function gen_func_body([FuncBody]$fbody) {
    if ($fbody.exit) {
        make_call $fbody.exit
    }
    if ($fbody.action) {
        make_call $fbody.action
    }
    if ($fbody.newState) {
        $index = $stateList | ? {$_.name -eq $fbody.newState} | % index
        "_state = $StateTypeName::$($fbody.newState);"
        "_row = &_table[$index][0];"
    }
    if ($fbody.enter) {
        make_call $fbody.enter
    }
    if ($fbody.actionAfterNewState) {
        make_call $fbody.actionAfterNewState
    }
}

function indent {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline = $true)]
        [string[]]$ss,
        [parameter(Position = 0)]
        [int]$n = 1
    )

    process {
        foreach ($s in $ss) {
            if ($s) {
                ('    ' * $n) + $s
            }
            else {
                ''
            }
        }
    }
}

function gen_func_defs() {
    $funcList | % {
        ""
        "void _func_$($_.id)()"
        "{"
        if ($_.branches) {
            $_.branches | % {$i = 0} {
                if ($_.cond -ne '_') {
                    $if = $i -eq 0 ? 'if' : 'else if'
                    $cond = $_.cond -replace '\b\w+\b','(static_cast<Derived*>(this))->$0()'
                    "    $if ($cond) {"
                        gen_func_body $_.body | indent 2
                    "    }"
                }
                else {
                    "    else {"
                    gen_func_body $_.body | indent 2
                    "    }"
                }
                $i++
            }
        }
        else {
            gen_func_body $_.body | indent
        }
        "}"
    }
}

function gen_csi() {
    $csiDict.Keys | sort | % {
        $ls = $csiDict[$_]
        ''
        "[[msvc::forceinline]] void CsiDispatch_$($_.ToString('X'))()"
        '{'
        '    (static_cast<Derived*>(this))->ActionCsiDispatch([=]() {'
        @(
            'const auto id = (static_cast<Derived*>(this))->FinalizeIdentifier(_wch);'
            $ls | % {$i=0} {
                $if = $i -eq 0 ? 'if' : 'else if'
                "$if (id == Derived::MakeVTID(`"$($_.id -replace '"', '\"')`")) {"
                "    return (static_cast<Derived*>(this))->engine().Csi_$($_.fn)((static_cast<Derived*>(this))->MakeVTParameters());"
                '}'
                $i++
            }
            'else {'
            '    return false;'
            '}'
        ) | indent 2
        '    });'
        '}'
    }

}

function gen_enters() {
    $stateList | % {
        ""
        "void Enter$($_.name)()"
        "{"
        "    _state = $StateTypeName::$($_.name);"
        "    _row = &_table[$($_.index)][0];"
        if ($_.enter) {
            make_call $_.enter | indent
        }
        "}"
    }
}

function gen_includes() {
    if ($Includes) {
        ''
        $Includes | % {
            $v = $_
            if ($v -notmatch '<(.+)>') { $v = "`"$v`"" }
            "#include $v"
        }
    }
}

function gen_enum() {
    if ($GenerateStateEnum) {
        ""
        "enum class $StateTypeName"
        "{"
        $StateList | % name | % { "    $_," }
        "};"
    }
}

function gen_names() {
    "static constexpr const wchar_t* _stateNames[] = {"
    $StateList | % name | % { "    L`"$_`"," }
    "};"
    ""
}

'// Generated by codegen.ps1'
'#pragma once'
gen_includes
if ($namespace) {
    ''
    "namespace $namespace {"
}
gen_enum
''
'template<class Derived>'
'class ParserGenerated'
'{'
'protected:'
'    wchar_t _wch = 0;'
"    $StateTypeName _state = $StateTypeName::$(@($States.Keys)[0]);"
"    const $funcIndexType* _row = &_table[0][0];"
"    static constexpr wchar_t kMaxChar = $MaxChar;"
''
'    template<bool InRange>'
'    void Proceed(wchar_t wch)'
'    {'
'        (static_cast<Derived*>(this))->OnProceed();'
'        _wch = wch;'
'        if constexpr(!InRange) { wch = wch > kMaxChar ? kMaxChar + 1 : wch; }'
'        (this->*(_funcs[_row[wch]]))();'
'    }'
''
'    void Invoke()'
'    {'
'        auto wch = _wch;'
'        wch = wch > kMaxChar ? kMaxChar + 1 : wch;'
'        (this->*(_funcs[_row[wch]]))();'
'    }'
''
gen_names | indent
gen_table | indent
gen_func_defs | indent
''
gen_func_array | indent
gen_csi | indent
gen_enters | indent
'};'
''
'/*'
$impls.Keys | %{"void $_() {}"}
'*/'
if ($namespace) {
    ''
    "} // namespace $namespace"
}
