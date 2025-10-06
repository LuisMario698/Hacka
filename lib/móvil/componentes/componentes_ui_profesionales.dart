import 'package:flutter/material.dart';
import '../tema/tema_profesional.dart';

/// AppBar consistente para toda la aplicación
class AppBarConsistente extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? acciones;
  final Widget? leading;
  final bool centrarTitulo;
  final Color? colorFondo;

  const AppBarConsistente({
    Key? key,
    required this.titulo,
    this.acciones,
    this.leading,
    this.centrarTitulo = false,
    this.colorFondo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Actualizar el sistema de colores según el tema activo
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return AppBar(
      elevation: 0,
      backgroundColor: colorFondo ?? PaletaProfesional.superficie,
      foregroundColor: PaletaProfesional.textoPrimario,
      centerTitle: centrarTitulo,
      leading: leading,
      title: Text(
        titulo,
        style: TextStyle(
          color: PaletaProfesional.textoPrimario,
          fontSize: TipografiaProfesional.h4,
          fontWeight: TipografiaProfesional.semibold,
          fontFamily: TipografiaProfesional.fontFamily,
        ),
      ),
      actions: acciones,
      iconTheme: IconThemeData(
        color: PaletaProfesional.textoPrimario,
        size: 24,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Botón primario profesional con diseño elegante
class BotonPrimarioProfesional extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool esCargando;
  final bool esCompleto;

  const BotonPrimarioProfesional({
    Key? key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.esCargando = false,
    this.esCompleto = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: esCompleto ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? PaletaProfesional.gradientePrimario
            : LinearGradient(
                colors: [
                  PaletaProfesional.textoTerciario,
                  PaletaProfesional.textoTerciario,
                ],
              ),
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        boxShadow: onPressed != null && !esCargando
            ? SombrasProfesionales.elevacion2
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: esCargando ? null : onPressed,
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: EspaciadoProfesional.lg,
              vertical: EspaciadoProfesional.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: esCompleto ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (esCargando) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PaletaProfesional.textoBlanco,
                      ),
                    ),
                  ),
                  SizedBox(width: EspaciadoProfesional.sm),
                ] else if (icono != null) ...[
                  Icon(
                    icono,
                    color: PaletaProfesional.textoBlanco,
                    size: 20,
                  ),
                  SizedBox(width: EspaciadoProfesional.sm),
                ],
                Text(
                  esCargando ? 'Cargando...' : texto,
                  style: TextStyle(
                    color: PaletaProfesional.textoBlanco,
                    fontSize: TipografiaProfesional.button,
                    fontWeight: TipografiaProfesional.semibold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario con borde profesional
class BotonSecundarioProfesional extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool esCompleto;

  const BotonSecundarioProfesional({
    Key? key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.esCompleto = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: esCompleto ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        color: PaletaProfesional.superficie,
        border: Border.all(
          color: onPressed != null
              ? PaletaProfesional.primario
              : PaletaProfesional.divider,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        boxShadow: onPressed != null ? SombrasProfesionales.elevacion1 : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: EspaciadoProfesional.lg,
              vertical: EspaciadoProfesional.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: esCompleto ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(
                    icono,
                    color: onPressed != null
                        ? PaletaProfesional.primario
                        : PaletaProfesional.textoTerciario,
                    size: 20,
                  ),
                  SizedBox(width: EspaciadoProfesional.sm),
                ],
                Text(
                  texto,
                  style: TextStyle(
                    color: onPressed != null
                        ? PaletaProfesional.primario
                        : PaletaProfesional.textoTerciario,
                    fontSize: TipografiaProfesional.button,
                    fontWeight: TipografiaProfesional.semibold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta profesional con diseño elegante
class TarjetaProfesional extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool elevada;
  final Color? colorBorde;

  const TarjetaProfesional({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevada = true,
    this.colorBorde,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaProfesional.fondoTarjeta,
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        border: Border.all(
          color: colorBorde ?? PaletaProfesional.divider,
          width: 1,
        ),
        boxShadow: elevada ? SombrasProfesionales.elevacion1 : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          child: Padding(
            padding: padding ?? EdgeInsets.all(EspaciadoProfesional.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto profesional
class CampoTextoProfesional extends StatelessWidget {
  final String? etiqueta;
  final String? pista;
  final TextEditingController? controlador;
  final bool esObscuro;
  final IconData? icono;
  final String? textoError;
  final TextInputType? tipoTeclado;
  final ValueChanged<String>? onChanged;
  final int? maxLineas;
  final bool habilitado;

  const CampoTextoProfesional({
    Key? key,
    this.etiqueta,
    this.pista,
    this.controlador,
    this.esObscuro = false,
    this.icono,
    this.textoError,
    this.tipoTeclado,
    this.onChanged,
    this.maxLineas = 1,
    this.habilitado = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (etiqueta != null) ...[
          Text(
            etiqueta!,
            style: TextStyle(
              color: PaletaProfesional.textoPrimario,
              fontSize: TipografiaProfesional.body2,
              fontWeight: TipografiaProfesional.medium,
            ),
          ),
          SizedBox(height: EspaciadoProfesional.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: habilitado
                ? PaletaProfesional.superficie
                : PaletaProfesional.fondoApp,
            borderRadius: BorderRadius.circular(RadiosProfesionales.md),
            border: Border.all(
              color: textoError != null
                  ? PaletaProfesional.peligro
                  : PaletaProfesional.divider,
              width: 1,
            ),
            boxShadow: SombrasProfesionales.elevacion1,
          ),
          child: TextField(
            controller: controlador,
            obscureText: esObscuro,
            keyboardType: tipoTeclado,
            onChanged: onChanged,
            maxLines: maxLineas,
            enabled: habilitado,
            style: TextStyle(
              color: PaletaProfesional.textoPrimario,
              fontSize: TipografiaProfesional.body1,
              fontWeight: TipografiaProfesional.regular,
            ),
            decoration: InputDecoration(
              hintText: pista,
              prefixIcon: icono != null
                  ? Icon(
                      icono,
                      color: PaletaProfesional.textoSecundario,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: EspaciadoProfesional.md,
                vertical: EspaciadoProfesional.md,
              ),
              hintStyle: TextStyle(
                color: PaletaProfesional.textoTerciario,
                fontSize: TipografiaProfesional.body1,
                fontWeight: TipografiaProfesional.regular,
              ),
            ),
          ),
        ),
        if (textoError != null) ...[
          SizedBox(height: EspaciadoProfesional.xs),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: PaletaProfesional.peligro,
                size: 16,
              ),
              SizedBox(width: EspaciadoProfesional.xs),
              Text(
                textoError!,
                style: TextStyle(
                  color: PaletaProfesional.peligro,
                  fontSize: TipografiaProfesional.caption,
                  fontWeight: TipografiaProfesional.regular,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Chip profesional con diseño elegante
class ChipProfesional extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final Color? color;
  final VoidCallback? onTap;
  final bool seleccionado;

  const ChipProfesional({
    Key? key,
    required this.texto,
    this.icono,
    this.color,
    this.onTap,
    this.seleccionado = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorFinal = color ?? PaletaProfesional.primario;
    
    return Container(
      decoration: BoxDecoration(
        color: seleccionado
            ? colorFinal.withOpacity(0.1)
            : PaletaProfesional.superficie,
        borderRadius: BorderRadius.circular(RadiosProfesionales.pill),
        border: Border.all(
          color: seleccionado ? colorFinal : PaletaProfesional.divider,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiosProfesionales.pill),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: EspaciadoProfesional.md,
              vertical: EspaciadoProfesional.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(
                    icono,
                    color: seleccionado ? colorFinal : PaletaProfesional.textoSecundario,
                    size: 16,
                  ),
                  SizedBox(width: EspaciadoProfesional.xs),
                ],
                Text(
                  texto,
                  style: TextStyle(
                    color: seleccionado ? colorFinal : PaletaProfesional.textoSecundario,
                    fontSize: TipografiaProfesional.body2,
                    fontWeight: seleccionado
                        ? TipografiaProfesional.medium
                        : TipografiaProfesional.regular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de estado profesional
class IndicadorEstadoProfesional extends StatelessWidget {
  final String estado;
  final Color color;
  final IconData icono;
  final bool conPulso;

  const IndicadorEstadoProfesional({
    Key? key,
    required this.estado,
    required this.color,
    required this.icono,
    this.conPulso = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget indicador = Container(
      padding: EdgeInsets.symmetric(
        horizontal: EspaciadoProfesional.md,
        vertical: EspaciadoProfesional.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(RadiosProfesionales.pill),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: EspaciadoProfesional.sm),
          Icon(
            icono,
            color: color,
            size: 16,
          ),
          SizedBox(width: EspaciadoProfesional.xs),
          Text(
            estado,
            style: TextStyle(
              color: color,
              fontSize: TipografiaProfesional.caption,
              fontWeight: TipografiaProfesional.medium,
            ),
          ),
        ],
      ),
    );

    if (conPulso) {
      return AnimatedContainer(
        duration: AnimacionesProfesionales.normal,
        child: indicador,
      );
    }

    return indicador;
  }
}