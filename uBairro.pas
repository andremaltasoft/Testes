namespace uBairro;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Windows.Forms,
  System.ComponentModel,
  System.Data,
  UITOBairro,
  USoftSystemINI,
  USoftSystemINIGenerica, 
  uConexaoServer, 
  UIBOFactory, 
  UIBOController, 
  UITOParametrosServer,
  uLogAlteracoes, 
  uPesquisaGenerica, 
  UITOCidade, 
  uCidade, 
  UITOGrupoUsuario,
  UITOArea,
  uArea;

type
  /// <summary>
  /// Summary description for uBairro.
  /// </summary>
  fBairro = partial class(FormSoft)
  private
    vShowModalNovo: Boolean;
    vTOBairro: ITOBairro;
    method limparCampos;
    method StatusCampos(Editavel: Boolean);

    method get_TOBairro(var TOBairro: ITOBairro); 
    method get_TOBairro(DR: DataRow); 
    method set_TOBairro(var TOBairro: ITOBairro);

    method SelecionarBairro(CodBairro: Integer);

    method tBarraBotoes1_AtualizarClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_CancelarClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_ExcluirClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_FecharClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_HistoricoClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_IncluirClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_ModificarClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_PesquisarClick(sender: System.Object; e: System.EventArgs);
    method tBarraBotoes1_SalvarClick(sender: System.Object; e: System.EventArgs);
    method fBairro_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method fBairro_Load(sender: System.Object; e: System.EventArgs);
    method edtCidadeCodigo_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method edtCidadeCodigo_TextChanged(sender: System.Object; e: System.EventArgs);
    method edtCidadeCodigo_Validated(sender: System.Object; e: System.EventArgs);
    method btnLocCidade_Click(sender: System.Object; e: System.EventArgs);
    method btnVerDadosCidade_Click(sender: System.Object; e: System.EventArgs);
    method edtCodArea_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method edtCodArea_TextChanged(sender: System.Object; e: System.EventArgs);
    method edtCodArea_Validated(sender: System.Object; e: System.EventArgs);
    method btnLocArea_Click(sender: System.Object; e: System.EventArgs);
    method btnVerDadosArea_Click(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method ShowModalNovo(var TOBairro: ITOBairro;CodCidade: Integer): System.Windows.Forms.DialogResult;
  end;

implementation

{$REGION Construction and Disposition}
constructor fBairro;
var
  ConexaoServer: fConexaoServer;
begin
  inherited Create;

  InitializeComponent;

  LimparCampos;
  StatusCampos(False);
  vShowModalNovo:= false;

  ConexaoServer := fConexaoServer.getConexao;  
  Self.Tag := ConexaoServer.ChecaPermissao(UINIGenerica.BAIRRO_VER);
  ConexaoServer.Dispose;  
end;


method fBairro.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method fBairro.limparCampos;
begin
  edtCodigo.Text := '';
  edtBairro.Text:= '';
  edtCidadeCodigo.Text := '';
  edtCidade.Text := '';
  edtCodArea.Text := '';
  edtArea.Text := '';
end;

method fBairro.StatusCampos(Editavel: Boolean);
begin
  TBarraBotoes1.Pesquisar_Enabled:= not(Editavel);
  TBarraBotoes1.Incluir_Enabled := not(Editavel);
  TBarraBotoes1.Modificar_Enabled := not(Editavel);
  TBarraBotoes1.Excluir_Enabled := not(Editavel);
  TBarraBotoes1.Salvar_Enabled := Editavel;
  TBarraBotoes1.Cancelar_Enabled := Editavel;
  TBarraBotoes1.Atualizar_Enabled := not(Editavel);
  TBarraBotoes1.Historico_Enabled := not(Editavel);
  TBarraBotoes1.Fechar_Enabled := not(Editavel);

  edtCodigo.Enabled := False;
  edtBairro.Enabled := Editavel;
  edtCidadeCodigo.Enabled := Editavel;
  edtCidade.Enabled := False;
  btnLocCidade.Enabled:= Editavel;
  btnVerDadosCidade.Enabled:= edtCidadeCodigo.Text.Trim <> '';
  edtCodArea.Enabled := Editavel;
  edtArea.Enabled := False;
  btnLocArea.Enabled := Editavel;
  btnVerDadosArea.Enabled:= UINIGenerica.StrToInt32(edtCodArea.Text) > 0;
end;

method fBairro.get_TOBairro(var TOBairro: ITOBairro);
begin
  edtCodigo.Text := TOBairro.CodBairro.ToString;
  edtBairro.Text := TOBairro.Bairro;
  edtCidadeCodigo.TextChanged -= edtCidadeCodigo_TextChanged;
  edtCidadeCodigo.Text := TOBairro.Cidade.CodCidade.ToString;
  edtCidadeCodigo.TextChanged += edtCidadeCodigo_TextChanged;
  edtCidade.Text := TOBairro.Cidade.Cidade;

  edtCodArea.TextChanged -= edtCodArea_TextChanged;
  edtCodArea.Text := TOBairro.AreaPadrao.CodArea.ToString;
  edtCodArea.TextChanged += edtCodArea_TextChanged;
  edtArea.Text := TOBairro.AreaPadrao.Area;
end;

method fBairro.get_TOBairro(DR: DataRow);
begin
  SelecionarBairro(UINIGenerica.StrToInt32(DR['CODBAIRRO'].ToString));
  btnVerDadosCidade.Enabled:= (edtCidadeCodigo.Text.Trim <> '');
  btnVerDadosArea.Enabled:= UINIGenerica.StrToInt32(edtCodArea.Text) > 0;
end;

method fBairro.set_TOBairro(var TOBairro: ITOBairro);
begin
  TOBairro.CodBairro := UINIGenerica.StrToInt32(edtCodigo.Text);
  TOBairro.Bairro := edtBairro.Text;
  TOBairro.Cidade.CodCidade := UINIGenerica.StrToInt32(edtCidadeCodigo.Text);
  TOBairro.AreaPadrao.CodArea := UINIGenerica.StrToInt32(edtCodArea.Text);
end;

method fBairro.SelecionarBairro(CodBairro: Integer);
var
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
  TOBairro: ITOBairro;
begin
  ConexaoServer := fConexaoServer.getConexao;
  ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
  ConexaoServer.Dispose;
  TOBairro := Factory.Bairro;

  if Controller.Bairro_Selecionar(ParametrosServer, CodBairro, TOBairro) then
  begin
    get_TOBairro(TOBairro);
    UINIGenerica.ShowInformacao(ParametrosServer.Erro);
  end
  else
    UINIGenerica.ShowErro(ParametrosServer.Erro);
end;


method fBairro.ShowModalNovo(var TOBairro: ITOBairro;CodCidade: Integer): System.Windows.Forms.DialogResult;
begin
  vShowModalNovo:= True;

  TBarraBotoes1_IncluirClick(TBarraBotoes1,nil);

  if CodCidade <> 0 then
  begin
    edtCidadeCodigo.Text:= CodCidade.ToString;
    edtCidadeCodigo_Validated(edtCidadeCodigo, nil);
  end;

  Result:= ShowDialog;
  if Result=System.Windows.Forms.DialogResult.ok then
    TOBairro:= vTOBairro;
end;

method fBairro.tBarraBotoes1_AtualizarClick(sender: System.Object; e: System.EventArgs);
begin
  if edtCodigo.Text = '' then
    LimparCampos
  else
    SelecionarBairro(UINIGenerica.StrToInt32(edtCodigo.Text));

  StatusCampos(False);
end;

method fBairro.tBarraBotoes1_CancelarClick(sender: System.Object; e: System.EventArgs);
begin
  if edtCodigo.Text = '' then
    LimparCampos
  else
    SelecionarBairro(UINIGenerica.StrToInt32(edtCodigo.Text));

  StatusCampos(False);

  if vShowModalNovo then
    DialogResult:= System.Windows.Forms.DialogResult.Cancel;
end;

method fBairro.tBarraBotoes1_ExcluirClick(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
begin
  if edtCodigo.Text <> '' then
    if UINIGenerica.ShowConfirmacao('Deseja realmente excluir este bairro?') then
    begin
      ConexaoServer := fConexaoServer.getConexao;
      ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
      ConexaoServer.Dispose;

      if Controller.Bairro_Excluir(ParametrosServer, UINIGenerica.StrToInt32(edtCodigo.Text)) then
      begin
        LimparCampos;
        StatusCampos(False);
        UINIGenerica.ShowInformacao(ParametrosServer.Erro);
      end
      else
        UINIGenerica.ShowErro(ParametrosServer.Erro);
    end;
end;

method fBairro.tBarraBotoes1_FecharClick(sender: System.Object; e: System.EventArgs);
begin
  if Self.IsMdiChild then
    Self.Close
  else
    Self.DialogResult := System.Windows.Forms.DialogResult.Cancel;
end;

method fBairro.tBarraBotoes1_HistoricoClick(sender: System.Object; e: System.EventArgs);
var
  LogAlteracoes: fLogAlteracoes;
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
  TOBairro: ITOBairro;
begin
  if edtCodigo.Text <> '' then
  begin
    ConexaoServer := fConexaoServer.getConexao;
    ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
    ConexaoServer.Dispose;

    TOBairro := Factory.Bairro;
    if Controller.Bairro_Selecionar(ParametrosServer,UINIGenerica.StrToInt32(edtCodigo.text),TOBairro) then
    begin
      LogAlteracoes := fLogAlteracoes.Create('BAIRRO','CODBAIRRO='+edtCodigo.Text,TOBairro.Padroes);
      LogAlteracoes.ShowDialog;
      ConexaoServer.Dispose;
    end
    else
      UINIGenerica.ShowErro(ParametrosServer.Erro);
  end
  else
    UINIGenerica.ShowInformacao('Você deve pesquisar um bairro primeiro!');
end;

method fBairro.tBarraBotoes1_IncluirClick(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
begin
  ConexaoServer := fConexaoServer.getConexao;
  if not(ConexaoServer.ChecaPermissao(UINIGenerica.BAIRRO_INCLUIR)) then
  begin
    ConexaoServer.Dispose;
    exit;
  end;

  ConexaoServer.Dispose;
  LimparCampos;
  StatusCampos(True);
  ActiveControl := edtBairro;
end;

method fBairro.tBarraBotoes1_ModificarClick(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
begin
  ConexaoServer := fConexaoServer.getConexao;
  if not(ConexaoServer.ChecaPermissao(UINIGenerica.BAIRRO_ALTERAR)) then
  begin
    ConexaoServer.Dispose;
    exit;
  end;

  ConexaoServer.Dispose;
  StatusCampos(True);
  ActiveControl := edtBairro;
end;

method fBairro.tBarraBotoes1_PesquisarClick(sender: System.Object; e: System.EventArgs);
var
  Pesquisa: fPesquisa;
  DR: DataRow;
begin
  Pesquisa := fPesquisa.Create('BAIRRO','BAIRRO');
  case Pesquisa.ShowModalSoft(DR) of
    System.Windows.Forms.DialogResult.Ignore: TBarraBotoes1_IncluirClick(TBarraBotoes1,e);
    System.Windows.Forms.DialogResult.OK:
    begin
      get_TOBairro(DR);
      disposeAndNil(DR);
    end;
  end;
  Pesquisa.Dispose;
end;

method fBairro.tBarraBotoes1_SalvarClick(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
  TOBairro: ITOBairro;
  Ok: Boolean;
begin
  ConexaoServer := fConexaoServer.getConexao;
  ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
  ConexaoServer.Dispose;

  TOBairro := Factory.Bairro;

  set_TOBairro(TOBairro);

  if edtCodigo.Text = '' then
    Ok := Controller.Bairro_Incluir(ParametrosServer, TOBairro)
  else
    Ok := Controller.Bairro_Alterar(ParametrosServer, TOBairro);

  if Ok then
  begin
    StatusCampos(False);
    get_TOBairro(TOBairro);

    UINIGenerica.ShowInformacao(ParametrosServer.Erro);
    if vShowModalNovo then
    begin
      vTOBairro:= Factory.Bairro;
      vTOBairro:= TOBairro;
      DialogResult:= System.Windows.Forms.DialogResult.OK;
    end;
  end
  else
    UINIGenerica.ShowErro(ParametrosServer.Erro);
end;

method fBairro.fBairro_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  case e.KeyCode of
    Keys.F12:
      if TBarraBotoes1.Pesquisar_Enabled then
        TBarraBotoes1_PesquisarClick(TBarraBotoes1,e);
    Keys.F3:
      if TBarraBotoes1.Incluir_Enabled then
        TBarraBotoes1_IncluirClick(TBarraBotoes1,e);
    Keys.F2:
      if TBarraBotoes1.Modificar_Enabled then
        TBarraBotoes1_ModificarClick(TBarraBotoes1,e);
    Keys.F7:
      if TBarraBotoes1.Excluir_Enabled then
        TBarraBotoes1_ExcluirClick(TBarraBotoes1,e);
    Keys.F4:
      if TBarraBotoes1.Salvar_Enabled then
        TBarraBotoes1_SalvarClick(TBarraBotoes1,e);
    Keys.F6:
      if TBarraBotoes1.Cancelar_Enabled then
        TBarraBotoes1_CancelarClick(TBarraBotoes1,e);
    Keys.F5:
      if TBarraBotoes1.Atualizar_Enabled then
        TBarraBotoes1_AtualizarClick(TBarraBotoes1,e);
    Keys.F8:
      if TBarraBotoes1.Historico_Enabled then
        TBarraBotoes1_HistoricoClick(TBarraBotoes1,e);
    Keys.F9:
      if TBarraBotoes1.Fechar_Enabled then
        TBarraBotoes1_FecharClick(TBarraBotoes1,e);
  end;
end;

method fBairro.fBairro_Load(sender: System.Object; e: System.EventArgs);
begin
  if not(Convert.ToBoolean(Self.Tag)) then
    DialogResult := System.Windows.Forms.DialogResult.Cancel;
end;

method fBairro.edtCidadeCodigo_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  if e.KeyChar=#13 then
    btnLocCidade_Click(btnLocCidade,e);

  UINIGenerica.AbortaString(edtCidadeCodigo, e, false);
end;

method fBairro.edtCidadeCodigo_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  edtCidadeCodigo.Tag :=1;
  btnVerDadosCidade.Enabled := edtCidadeCodigo.Text.Trim <> '';
end;

method fBairro.edtCidadeCodigo_Validated(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
  Cidade: ITOCidade;
begin
  if UINIGenerica.StrToInt32(edtCidadeCodigo.Text) <> 0 then
    if UINIGenerica.StrToInt32(edtCidadeCodigo.Tag.ToString) = 1 then
    begin
      ConexaoServer := fConexaoServer.getConexao;
      ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
      ConexaoServer.Dispose;

      Cidade := Factory.Cidade;
      if Controller.Cidade_Selecionar(ParametrosServer,UINIGenerica.StrtoInt32(edtCidadeCodigo.Text),Cidade) then
      begin
        UINIGenerica.ShowInformacao(ParametrosServer.Erro);
        edtCidade.Text := Cidade.Cidade;
      end
      else
      begin
        UINIGenerica.ShowErro(ParametrosServer.Erro);
        edtCidade.Text := '';
        ActiveControl := edtCidadeCodigo;
        exit;
      end;
    end
    else
  else
    edtCidade.Text := '';

  edtCidadeCodigo.Tag := 0;
end;

method fBairro.btnLocCidade_Click(sender: System.Object; e: System.EventArgs);
var
  Pesquisa: fPesquisa;
  DR: DataRow;
  Cidade: fCidade;
  TOCidade: ITOCidade;
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
begin
  Pesquisa := fPesquisa.Create('CIDADE','CIDADE');
  case Pesquisa.ShowModalSoft(DR) of
    System.Windows.Forms.DialogResult.Ignore:
    begin
      Cidade:= fCidade.Create;
      ConexaoServer := fConexaoServer.getConexao;
      ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
      ConexaoServer.Dispose;

      TOCidade := Factory.Cidade;
      if Cidade.ShowModalNovo(TOCidade,0)=  System.Windows.Forms.DialogResult.OK then
      begin
        edtCidadeCodigo.Text:= TOCidade.CodCidade.ToString;
        edtCidade.Text:= TOCidade.Cidade;
      end;
      Cidade.Dispose;
    end;

    System.Windows.Forms.DialogResult.OK:
    begin
      edtCidadeCodigo.Text:= dr['CODCIDADE'].ToString;
      edtCidade.Text:= dr['CIDADE'].ToString;
      disposeAndNil(DR);
    end;
  end;
  Pesquisa.Dispose;
end;

method fBairro.btnVerDadosCidade_Click(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Cidade: fCidade;
begin
  ConexaoServer:= fConexaoServer.getConexao;
  if not(ConexaoServer.ChecaPermissao(UINIGenerica.CIDADE_VER)) then
  begin
    ConexaoServer.Dispose;
    Exit;
  end;

  ConexaoServer.Dispose;
  Cidade:= fCidade.Create(UINIGenerica.StrToInt32(edtCidadeCodigo.Text));
  Cidade.ShowDialog;
  Cidade.Dispose;
end;

method fBairro.edtCodArea_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  if e.KeyChar=#13 then
   btnLocArea_Click(btnLocArea,e);

  UINIGenerica.AbortaString(edtCodArea, e, true);
end;

method fBairro.edtCodArea_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  edtCodArea.Tag := 1;
  btnVerDadosArea.Enabled:= UINIGenerica.StrToInt32(edtCodArea.Text) > 0;
end;

method fBairro.edtCodArea_Validated(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
  Area: ITOArea;
begin
  if UINIGenerica.StrToInt32(edtCodArea.Text) <> 0 then
    if UINIGenerica.StrToInt32(edtCodArea.Tag.ToString) = 1 then
    begin
      ConexaoServer := fConexaoServer.getConexao;
      ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
      ConexaoServer.Dispose;

      Area := Factory.Area;

      if Controller.Area_Selecionar(ParametrosServer,UINIGenerica.StrToInt32(edtCodArea.Text),Area) then
      begin
        UINIGenerica.ShowInformacao(ParametrosServer.Erro);

        edtArea.Text := Area.Area;
      end
      else
      begin
        UINIGenerica.ShowErro(ParametrosServer.Erro);

        edtArea.Text := '';

        ActiveControl := edtCodArea;

        Exit;
      end;
    end
    else
  else
    edtArea.Text := '';

  edtCodArea.Tag := 0;
end;

method fBairro.btnLocArea_Click(sender: System.Object; e: System.EventArgs);
var
  Pesquisa: fPesquisa;
  DR: DataRow;
  Area: fArea;
  TOArea: ITOArea;
  ConexaoServer: fConexaoServer;
  Factory: IBOFactory;
  Controller: IBOController;
  ParametrosServer: ITOParametrosServer;
begin
    Pesquisa := fPesquisa.Create('AREA','AREA');
    case Pesquisa.ShowModalSoft(DR) of
        System.Windows.Forms.DialogResult.Ignore:
        begin
           Area:= fArea.Create;

           ConexaoServer := fConexaoServer.getConexao;
           ConexaoServer.ActivatorObject(Factory,Controller,ParametrosServer);
           ConexaoServer.Dispose;

           TOArea := Factory.Area;
           if Area.ShowModalNovo(TOArea)=  System.Windows.Forms.DialogResult.OK then
           begin
            edtCodArea.Text:= TOArea.CodArea.ToString;
            edtArea.Text:= TOArea.Area;
           end;
           Area.Dispose;
        end;
        System.Windows.Forms.DialogResult.OK:
        begin
            edtCodArea.Text:= dr['CODAREA'].ToString;
            edtArea.Text:= dr['AREA'].ToString;
        end;
    end;
    Pesquisa.Dispose;
    disposeAndNil(DR);
end;

method fBairro.btnVerDadosArea_Click(sender: System.Object; e: System.EventArgs);
var
  ConexaoServer: fConexaoServer;
  Area: fArea;
begin
  ConexaoServer:= fConexaoServer.getConexao;
  if not(ConexaoServer.ChecaPermissao(UINIGenerica.AREA_VER)) then
  begin
    ConexaoServer.Dispose;
    Exit;
  end;

  ConexaoServer.Dispose;
  Area:= fArea.Create(UINIGenerica.StrToInt32(edtCodArea.Text));
  Area.ShowDialog;
  Area.Dispose;
end;

end.
